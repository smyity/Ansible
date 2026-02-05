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

- [Установка Kubernetes v1.35 (kubeadm, kubectl, kubelet)](files/001_install_kubernetes_v_1_35/playbook.yml)
- [Проверка серверов (Ping)](files/002_ping/playbook.yml)
- [Установка Kubernetes v1.35, HELM, инициализация master-node и добавление worker-nodes](files/003_install_kubernetes_v_1_35+kubeinit/playbook.yml)
- [Установка Zabbix server и agent v7.4 для Ubuntu 22.04](files/004_install_zabbix_v_7_4/playbook.yml) или использовать [bash-скрипт установки только Zabbix server v7.4](files/004_install_zabbix_v_7_4/install_zabbix_serv.sh)
- [Установка Docker](files/005_install_docker/playbook.yml)
  - [Развертывание мониторинга Grafana, Node Exporter, Prometheus](files/006_deploy_monitoring_in_docker/playbook.yml) + [manual](files/006_deploy_monitoring_in_docker/manual.md) по настройке

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

-----

- Для запуска контейнеров через Docker Compose
> [!WARNING]
> Перед запуском должна быть установлена коллекция **community.docker** где запускается **ansible-playbook**.\
> Команда: `ansible-galaxy collection install community.docker`

```yaml
- name: Тест
  hosts: all

  tasks:
    - name: Запуск проекта через Docker Compose
      community.docker.docker_compose_v2:
        project_src: путь к docker-compose.yml на сервере
        state: present
```

-----

- Для быстрого комментирования в VS Code можно выделить нужные строки и нажать сочетание клавиш `Ctrl` + `/`. Это своего рода переключатель - так что раскомментировать так же.

-----

- Применение условия **notify** + **handler**. Оно сработает только если файл реально изменился. Если файл уже на месте и он правильный, перезагрузки не будет.

Так же можно использовать модуль, который будет принудительно использовать **handlers** (*перезапускать приложение*) сразу же, а не в конце сценария.

```yml
    - name: Distribute cookie to others
      ansible.builtin.copy:
        src: "./temp_cookie"
        dest: "{{ item }}"
        owner: rabbitmq
        group: rabbitmq
        mode: '0400'
      loop: ["/var/lib/rabbitmq/.erlang.cookie", "/root/.erlang.cookie"]
      notify: Restart RabbitMQ

    - name: Принудительно использовать handlers прямо сейчас
      ansible.builtin.meta: flush_handlers

    - name: Create admin user
      community.rabbitmq.rabbitmq_user:
        user: "{{ rabbit_user }}"
        password: "{{ rabbit_pass }}"
        tags: administrator
        permissions:
          - vhost: "/"
            configure_priv: ".*"
            write_priv: ".*"
            read_priv: ".*"
        state: present
      when: inventory_hostname == primary_node

  handlers:
    - name: Restart RabbitMQ
      ansible.builtin.service:
        name: rabbitmq-server
        state: restarted
```

-----

- можно использовать условие с использованием **register**:

```yml
    - name: Копирование файла cookie
      ansible.builtin.copy:
        src: "./temp_cookie"
        dest: /var/lib/rabbitmq/.erlang.cookie
        owner: rabbitmq
        group: rabbitmq
        mode: '0400'
      register: cookie_status # Регистрируем результат: изменился файл или нет

    - name: Перезапуск RabbitMQ (только если куки обновился)
      ansible.builtin.systemd:
        name: rabbitmq-server
        state: restarted
      when: cookie_status.changed

    - name: Ожидание готовности RabbitMQ
      ansible.builtin.wait_for:
        port: 5672
        host: "{{ ansible_host }}"
        delay: 5
        timeout: 60
      when: cookie_status.changed # Ждем только если был рестарт
```

-----

- Задать условия при которых статус модуля будет считаться `failed`

```yml
    - name: Добавление в кластер
      shell: |
        rabbitmqctl stop_app
        rabbitmqctl join_cluster rabbit@{{ master_node }}
        rabbitmqctl start_app
      when: inventory_hostname != master_node
      register: cluster_join
      failed_when: 
        - cluster_join.rc != 0 # Return Code (код возврата)
        - "'already_member' not in cluster_join.stderr" # Специфическая строка которую RabbitMQ выдает в консоль (stderr), если пытаться добавить узел в кластер, в котором он уже состоит
```

Где:

`<register>.rc` - вывод кода возврата

`<register>.stderr` - вывод из потока ошибок

- Условие выполнения:

```yml
when: inventory_hostname == user_x.changed
```
Это означает, что модуль запустится если статус `register: user_x` будет `changed`

-----

- **Синтаксис условий**:

Логические операторы:

`and` — логическое И (вместо &&)

`or` — логическое ИЛИ (вместо ||)

`not` — отрицание (вместо !)

-----

Увидеть все переменные хоста:

```yml
  tasks:
    - name: Просмотр всех доступных данных (Magic) хоста
      debug:
        var: hostvars[inventory_hostname]
```

---

[ПРАВИЛА ОФОРМЛЕНИЯ ФАЙЛА README.MD](https://docs.github.com/ru/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)
