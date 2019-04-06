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

ДЗ №7 

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
    





