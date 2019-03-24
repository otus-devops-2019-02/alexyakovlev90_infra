# alexyakovlev90_infra
alexyakovlev90 Infra repository




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

bastion_IP = 130.211.63.102
someinternalhost_IP = 10.132.0.3

