# Версии ZX Evolution

## Revision A
Прототип ZX Evolution, платы этой ревизии есть только у разработчиков и в продажу не поступали.

## Revision B
Редкая в наше время зелёная плата под mATX/ATX корпус, серийное производство до 2011, затем была заменена на Revision C.

## Revision C
Наиболее распротранённая версия ZX Evolution. Красная плата под mini ITX, серийное производство до 2015, затем производство передано [Tetroid](http://tetroid.nedopc.com)
 - [Руководство пользователя](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2Fdocs%2FrevC%2Fzxevo_user_manual.pdf)
 - [Принципиальная схема](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2Fdocs%2FrevC%2Fzxevo_sch_revc.pdf)
 - [Руководство по сборке и настройке](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2Fdocs%2FrevC%2Fzxevo_solder.pdf)
 - [Монтажная схема](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2Fdocs%2FrevC%2Fzxevo_mon_revc.pdf)
 - [Список компонетов (BOM)](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2Fdocs%2FrevC%2Fzxevo_bom_revc.pdf)


## Revision CS2 от Олега Solegstar
Отличия от Revsiosn C:
- Added HDAUDIO connector.
- Added MICRO-SD slot.
- X9 is KEMPSTON SEGA GAMEPAD connector, and second redefine GAMEPAD, not RS232 now.
- X19 is RS232 TTL-standard.
- BAT54C replaced by SS14.
- ATX connector is universal for 4.2/5.5 pins step.
- Added EXT_VGA connector for External video source, like VDAC2 or etc.
- Replaced FT232 to CP2102.

Файлы
- [Принципиальня схема](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2Fpcad%2Fsolegstar%2F04_rev_cs2%2Fzx-evo_rev_cs2_album.pdf)


## Revision D (в разработке)

В мае 2026 Вадим LVD и Роман CHRV обхявили о разработке новой модели ZX Evolution
- [Анонс на Youtube](https://www.youtube.com/watch?v=C9WL0ML8Pbs)
- [KiCad проект на SVN](http://svn.nedopc.com/listing.php?repname=pentevo&path=%2Fkicad%2Frev_d%2B%2F)

Заявленные улучшения:
- AVR будет заменён на Risk-V
- Новый аудиотракт с отдельной регулировкой громкости каждого источника
- Улучшен Beeper
- Две SD-карты. Одна для основного компьютера, другая для контроллера. Сменой карты контроллера можно менять конфигурации без перепрошивки.