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



