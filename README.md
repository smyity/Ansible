![](pic/ansible_logo.png)

Содержимое директории **ansible** (standart)
```
ansible/
├── inventory.ini
└── playbook.yml
```

Содержимое файла **inventory.ini**
```ini
[serv]
ИМЯ_ХОСТА ansible_host=IP-АДРЕС ansible_user=ИМЯ_ПОЛЬЗОВАТЕЛЯ ansible_ssh_private_key_file=ПУТЬ_К_ПРИВАТНОМУ_КЛЮЧУ
```
Запуск **ansible**
```
ansible-playbook -i inventory.ini playbook.yml
```
-----

### Vault

В директории с playbook.yml создать файл secrets.yml с помощью команды:
```
ansible-vault create secrets.yml
```
Ввесть пароль

Содержимое файла secrets.yml
```yaml
ПЕРЕМЕННАЯ: "ЗНАЧЕНИЕ"
```

В playbook.yml вставить переменную
```yaml
password: "{{ ПЕРЕМЕННАЯ }}"
```

```
ansible/
├── inventory.ini
├── playbook.yml
└── secrets.yml
```
Для запуска **playbook** команда нужна с запросом пароля:

```
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass
```

-----

[Установка Kubernetes (kubeadm, kubectl, kubelet)](files/001_install_kubernetes_v_1_35/playbook.yml)\
[Проверка серверов (Ping)](files/002_ping/playbook.yml)\
[Установка Kubernetes, HELM, инициализация master-node и добавление worker-nodes](files/003_install_kubernetes_v_1_35+kubeinit/playbook.yml)

---

[ПРАВИЛА ОФОРМЛЕНИЯ ФАЙЛА README.MD](https://docs.github.com/ru/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)