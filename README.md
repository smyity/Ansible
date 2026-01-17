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

В директории с **playbook.yml** создать файл **secrets.yml** с помощью команды:
```
ansible-vault create secrets.yml
```
далее ввести пароль
  

Структура директории:
```
ansible/
├── inventory.ini
├── playbook.yml
└── secrets.yml
```

Содержимое файла **secrets.yml**
```yaml
ПЕРЕМЕННАЯ: "ЗНАЧЕНИЕ"
```

В **playbook.yml** вставить переменную
```yaml
- name: Test
  hosts: all
  become: true
  vars_files: # Добавить файл с переменными
    - secrets.yml

password: "{{ ПЕРЕМЕННАЯ }}"
```

Для запуска **playbook** команда нужна с запросом пароля:

```
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass
```

Редактирование зашифрованного файла:
```
ansible-vault edit secrets.yml
```

-----

[Установка Kubernetes v1.35 (kubeadm, kubectl, kubelet)](files/001_install_kubernetes_v_1_35/playbook.yml)\
[Проверка серверов (Ping)](files/002_ping/playbook.yml)\
[Установка Kubernetes v1.35, HELM, инициализация master-node и добавление worker-nodes](files/003_install_kubernetes_v_1_35+kubeinit/playbook.yml)\
[Установка Zabbix server v7.4 для Ubuntu 22.04](files/004_install_zabbix_v_7_4/playbook.yml) или использовать [bash-скрипт](files/004_install_zabbix_v_7_4/install_zabbix_serv.sh)\
[Установка Docker](files/005_install_docker/playbook.yml)

---
### ПОЛЕЗНО

- Если нужно протестировать playbook до определенного момента, то после нужного модуля можно поставить модуль:\
  `- meta: end_play`

```yaml
- name: Тест
  hosts: all
  become: true

  tasks:
    - name: Тест ping
      ping:

    - meta: end_play  # Плейбук остановится здесь

    - name: 1. Обновление cache
      apt:
        update_cache: yes
```

Для быстрого комментирования в VS Code можно выделить нужные строки и нажать сочетание клавиш `Ctrl` + `/`. Это своего рода переключатель - так что раскомментировать так же.

[ПРАВИЛА ОФОРМЛЕНИЯ ФАЙЛА README.MD](https://docs.github.com/ru/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)
