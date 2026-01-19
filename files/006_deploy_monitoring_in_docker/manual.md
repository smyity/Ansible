## Настройка мониторинга

В адресной строке ввести **адрес сервера**: `ip сервера`:`порт`

Пример: 

```
158.160.98.2:3000
```

![](https://github.com/smyity/Ansible/blob/main/pic/MonitoringGrafana001.PNG)

Ввести **login** и **password**:
```
login: admin
password: admin
```

![](Ansible/pic/MonitoringGrafana002)

**Connections** --> **Data sources** --> **Add data source** --> **Prometheus**

В поле **Connection** написать:
```
http://prometheus:9090
```

![](Ansible/pic/MonitoringGrafana003)

**Dashboards** --> **Create dashboard** --> **Import dashboard**

В поле импорта ID ввести ID нужного шаблона (к примеру **1860**) и нажать **Load** --> **Import**

![](Ansible/pic/MonitoringGrafana004)

Готово!

![](Ansible/pic/MonitoringGrafana005)

Во вкладке `Nodename` можно переключаться между серверами.