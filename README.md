# alexyakovlev90_infra
alexyakovlev90 Infra repository


### ДЗ №3. Подключение к ВМ по SSH, через бастион-хост и VPN

bastion_IP = 130.211.63.102
someinternalhost_IP = 10.132.0.3

1. Подключение к серверу внутренней сети через bastion с пробрасыванием авторизации
```$xslt
ssh -i ~/.ssh/appuser -A appuser@bastion_IP ssh someinternalhost_IP
```
`130.211.63.102` - bastion  
`10.132.0.3` - someinternalhost


2. Подключение из консоли командой `ssh someinternalhost` –
добавляем в `~/.ssh/config`
```$xslt
Host bastion
        Hostname bastion_IP
        User appuser
        ForwardAgent yes

Host someinternalhost
        Hostname someinternalhost_IP
        User appuser
        ProxyCommand ssh -i ~/.ssh/appuser bastion nc %h %p
```


### ДЗ №4 Деплой тестового приложения

testapp_IP = 35.232.34.209  
testapp_port = 9292

1. Создание ВМ со стартовым скриптом
```
gcloud compute instances create startup-test-app \
--metadata-from-file startup-script=startup.sh \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure
```

2. Открываем порт в файрволе
```
gcloud compute firewall-rules create default-puma-server \
--allow=tcp:9292 \
--source-ranges='0.0.0.0/0' \
--target-tags puma-server
```

### ДЗ №5 Подготовка базового образа VM при помощи Packer

1. Запуск параметризированной конфигурации 
```
packer build \
    -var-file=variables.json \
    immutable.json
```

### ДЗ №6 Декларативное описание в виде кода инфраструктуры GCP в Terraform

1. При добавлении нескольких публичных ssh ключей в коде Terraform 
получится залогиниться на ВМ только по последнему ключу. Для остальных 
пользователей будет выводиться Permission denied (publickey). Добавленный 
в веб интерфейсе ssh ключ будет также рабочим.

2. При добавлении конфигурации копированием описания инстанца появляется 
дублирование кода и возникает проблема обновления скриптов при котором 
инстанцы со временем могут начать отличаться друг от друга

### ДЗ №7 Создание Terraform модулей для управления компонентами инфраструктуры.

1. Для настройки хранение стейт файла в удаленном бекенде описание бекенда 
нужно вынести в отдельный файл `backend.tf` с командой:
```
terraform {
  backend "gcs" {
    bucket  = "bucket-p"
    prefix  = "terraform/state"
  }
}
```
При переносе конфигурационных файлов Terraform в произвольную директорию 
Terraform видит текущее состояние инфраструктуры независимо от директории. 
При одновременном выполнении команды `terraform apply` будет срабатывать блокировка
    
2. Для деплоя приложения добавляем необходимые файлы и provisioner'ы 
в модуль приложения:
```
  provisioner "remote-exec" {
    inline = [
      "export DATABASE_URL=${var.mongo_url}",
    ]
  }

  # copy file
  provisioner "file" {
    source      = "${path.module}/files/puma.service"
    destination = "/tmp/puma.service"
  }
    
  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
```
для передачи внутряннего ip БД исползуем внешнюю переменную в `db` модуле:  
```
output "private_ip" {
    value = "${google_compute_instance.db.network_interface.0.network_ip}"
}
```
    
### ДЗ №8 Написание Ansible плейбуков на основе имеющихся bash скриптов

1. Запуск плейбука после выполния `ansible app -m command -a 'rm -rf ~/reddit'`
    - Т.к. директория приложения была удалена, повторное выполнение 
    `ansible-playbook clone.yml` приводит к повторному скачиванию репозитория.

2. Для запуска конфигурации инвентори в JSON используем команду  
    `ansible all -i ./inventory.json -m ping`

3. Разница между статическим и динамическим инвентори
- статический:
```json
{
  "app": {
    "hosts": {
      "appserver": {
        "ansible_host": "35.195.184.42"
      }
    }
  },
  "db": {
    "hosts": {
      "dbserver": {
        "ansible_host": "35.233.10.228"
      }
    }
  }
}
```
- динамический

```json
{
  "_meta": {
    "hostvars": {}
  },
  "app": {
    "hosts": [
      "35.195.184.42"
    ],
    "vars": {}
  },
  "db": {
    "hosts": [
      "35.233.10.228"
    ],
    "vars": {}
  }
}
```

### ДЗ №9 Управление настройками хостов и деплой приложения при помощи Ansible.
Задание со * - использования dynamic inventory для GCP.
Для использования dynamic inventory выбран gcp_compute, указанный в 
https://docs.ansible.com/ansible/latest/scenario_guides/guide_gce.html#gce-dynamic-inventory
как наболее удобное решение

Документация по использованию плагина: 
http://docs.testing.ansible.com/ansible/latest/plugins/inventory/gcp_compute.html

Порядок действий: 
- добавляем gcp_compute в список плагинов в ansible.cfg
- создаем yml файл конфигурации dynamic inventory, заканчивающийся на .gcp.yml
- указываем данный инвентори в ansible.cfg
- для ссылки на внутренний/внешний ip прописываем в dynamic inventory в разделе 
compose параметры хостов
