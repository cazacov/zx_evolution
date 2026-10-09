# Конфигурации

ZX Evolution превращается в ZX Spectrum совместимый компьютер установкой "конфигурации" - кода для микроконтроллера и FPGA.

**Микроконтроллер ATMEGA128**

Управляет периферией: клавиатура, мышь, SD-карточка, последовательный порт, джойстик. Управляет ATX блоком питания, формирует Reset FPGA, при этом сам ATMEGA128 продолжает работу (Soft reset). Так же микроконтроллер загружает конфигурацию в FPGA при включении питания и по Hard reset.

**FPGA Altera EP1K50QC208**

После заливки конфигурации становится клоном спектрума, формирует видеосигнал, работает со звуком AY, контроллером дисковода, слотами расширения ZX Bus.

**Порядок прошивки**
1. Загружаем в ATMEGA128 bootloader при помощи программатора
2. Загружаем TestConf с SD-карты или по последовательному порту
3. Тестируем ZX Evo средствами TestConf
4. Загружаем ROM через меню TestConf
5. Загружаем конфигурацию с SD-карты или по последовательному порту

[Видео как прошить ZX Evolution с нуля](https://www.youtube.com/watch?v=mWB4m5wStyA)

## AVR Bootloader
В микроконтроллер ATMEGA128 должен быть однократно записан bootloader. Это делается программатором. Код стабильный и не менялся с 2012 года, если ZX Evolution вам достался готовым и протестированным, скорей всего bootloader уже установлен. Его назначение после hard reset найти конфигурацию на SD карточке или получить её по последовательному порту и загрузить код в flash-память микроконтроллер ATMEGA128 (а тот в свою очередь запрограммирует FPGA). Вот новые прошивки ATMEGA и Altera выходят весьма часто, и говоря об установки конфигурации обычно имеют в виду именно их.

Документация по прошивке Bootloader:
- [bootloadr.pdf](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2Favrboot%2Ftrunk%2Fbootloader.pdf)


## Файлы конфигурации

Классические компьютеры имеет некоторую конфигурацию "железа" плюс BIOS - набор микропрограмм в ПЗУ которые запускают компьютер и загружают операционную систему. Аналогично ZX Evolution файл конфигурации определяет структуру связей в FPGA и функции периферии подключённой к ATMEGA. Загружая разные конфигурации мы по сути разные компьютеры, например BaseConf и TSConf поддерживюь разные видеорежимы. Конфигурация FPGA находится внутри файла конфигурации ATMEGA. При включении ATMEGA заливает конфигурацию в FPGA Altera.

ROM-файл это код который будет запущен на FPGA после его инициализации и является в некотором роде его программой BIOS.

Файл конфигураци имеет название ZXEVO_FW.BIN и размер 50-60 Кб.

Файлы ROM заливаются в флэш-память 29F040 и имеют размер ровно 524288 байт.

Сперва прошивается конфигурация, из неё уже можно записать в flash файл ROM. Конфигурацию можно прошить по последовательному порту или с SD карты, монитор/телевизор при этом не требуется.

## TestConf

Cервисная конфигурация для тестирования и настройки ZXEvo. Состоит из единственного файла `zxevo_fw.bin`, ROM файл не требуется.
- [Английская версия](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2Ftest_n_service%2Ftrunk%2Feng%2Fzxevo_fw.bin)
- [Русская версия](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2Ftest_n_service%2Ftrunk%2Frus%2Fzxevo_fw.bin)

Размер файла `zxevo_fw.bin` - 65K. Так как имя файла жёстко закодированно в AVR bootloader, в репозитории ZX Evolution в разных папках лежит несколько файлов различных конфигурация с одинаковым именем, будте внимательны!

### Загрузка конфигурации с SD карты
- Отформатировать карту в FAT32
- Положить файл zxevo_fw.bin в корень
- Зажать Soft Reset (J6 на Revision C)
- Подать питание, включив БП в розетку (или нажать hard reset J9)
- Через пару секунд разомкнуть SoftReset
- Через 10 секунд выключить и включить снова

### Загрузка по COM-порту

Файл прошивки можно залить на ZX Evo через RS-232 и нульмодемный кабель как [описано в инструкции](../../docs/ZXEvo_firmware_update.md#обновление-с-помощью-нуль-модемного-кабеля), но проще поключить его к PC черз USB кабель. На выведенном на заднюю панель ZX Evolution разъёме X13 Micro USB чип FT232 уже правильно подключён к Evo UART порту с перекрещенными сигналами RX и TX. В официальной документации Evo рекомендуется использовать входившую в Windows 89-XP программу HyperTerminal, но в наше время лучше взять более современный софт с поддержкой протокола X-Modem, например [Tera Term](https://github.com/TeraTermProject/teraterm/releases/tag/v5.7.0)

- Соединяем PC с ZX Evo шнуром USB <-> Micro USB
- Включаем ZX Evo
- В Windows Device Manager смотрим номер появившегося COM порта
- В терминальной программе устанавливаем соединение Speed `115200`, `8 bit`, parity: `none`, `2` stop bits, flow control: `none`.
- Зажимаем Soft Reset
- Коротко нажимаем Hard Reset
- Отпускаем Soft Reset

Должно появиться:
```
 ��������
 ��������  ����� �   �  �����
��������     ��   ���   ����  �   � �����
�������    ��    �� ��  �     �� �� �   �
������     ����� �   �  �����   �    ���

boot: ZXEvoAVRBoot 23.01.2012
main: Test&Service 28.06.2020 beta

Set temporary configuration...
Try update from SD-card...
SD error: Card not found
Try update from RS-232...
Now, start file transfer using X-Modem-CRC protocol.
```

Отправляем по X-Modem файл zxevo_fw.bin
В Tera Term это `File -> Transfer -> XMODEM -> Send`

Заливка идёт несколько секунд, в терминале появится:

```
Try update from RS-232...

Recheck flash...   Ok!

main: Test&Service 04.01.2016 beta

�


          ZX Evolution Test&Service (160104)

ATMEGA128 pins check... No problems found.
Status of POWERGOOD=0, VCC5=0
ATX power up...
Status of POWERGOOD=1, VCC5=1
Set FPGA configuration... Done.
FPGA data exchange test... Ok.
PS/2 keyboard check...
FF FA AA F2 FA AB 83 F0 FA 02 FA F3 FA 00 FA
---

          ZX Evolution Test&Service (160104)
   Sensors:       No card           Read only
Card initialization...
No SD/MMC card found.
Diagnostic is complete.
```

## BaseConf

Базовая конфигурация, разрабатываемая группой NedoPC.
Файлы:
- [ROM zxevo_fe.rom](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2From%2Fzxevo_fe.rom)
- [BaseConf zxevo_fw.bin](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2Fcfgs%2Fstandalone_base_trdemu%2Ftrunk%2Fzxevo_fw.bin)


## TSConf