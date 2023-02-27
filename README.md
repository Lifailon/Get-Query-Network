# Get-Query-Network

Дополнение для модуля **[Get-Query](https://github.com/Lifailon/Get-Query)**. Используется для сканирования подсети на наличие активных серверов с ОС Windows и просмотра на них списка пользователей.

## Зависимости:
* **Module [PoshRSJob](https://github.com/proxb/PoshRSJob)** - применяется в процессе пинг подсети (ускорения работы);
* **Module ActiveDirectory (RSAT)** - для проверки версии ОС и Resove Name (увеличивает время работы, сравнительно с проверками wmi и nslookup);
* **Module Get-Query** - для сбора списка пользователей.

![Image alt](https://github.com/Lifailon/Get-Query-Network/blob/rsa/Screen/Get-Help-and-Run-Time.jpg)

### Вывод в GridView с возможность поиска пользователя (сортировки) и подключения к нему по средствам Remote Desktop Shadow:

![Image alt](https://github.com/Lifailon/Get-Query-Network/blob/rsa/Screen/Shadow.jpg)

### Вывод в таблицу Excel:

![Image alt](https://github.com/Lifailon/Get-Query-Network/blob/rsa/Screen/Output-xml.jpg)
