// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurahProgressAdapter extends TypeAdapter<SurahProgress> {
  @override
  final int typeId = 0;

  @override
  SurahProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurahProgress(
      surahNumber: fields[0] as int,
      surahName: fields[1] as String,
      memorizedAyahs: (fields[2] as List).cast<int>(),
      totalAyahs: fields[3] as int,
      lastStudied: fields[4] as DateTime,
      totalMinutesStudied: fields[5] as int,
      totalSessions: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SurahProgress obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.surahNumber)
      ..writeByte(1)..write(obj.surahName)
      ..writeByte(2)..write(obj.memorizedAyahs)
      ..writeByte(3)..write(obj.totalAyahs)
      ..writeByte(4)..write(obj.lastStudied)
      ..writeByte(5)..write(obj.totalMinutesStudied)
      ..writeByte(6)..write(obj.totalSessions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurahProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FavoriteAyahAdapter extends TypeAdapter<FavoriteAyah> {
  @override
  final int typeId = 1;

  @override
  FavoriteAyah read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteAyah(
      surahNumber: fields[0] as int,
      surahName: fields[1] as String,
      ayahNumber: fields[2] as int,
      ayahText: fields[3] as String,
      savedAt: fields[4] as DateTime,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteAyah obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.surahNumber)
      ..writeByte(1)..write(obj.surahName)
      ..writeByte(2)..write(obj.ayahNumber)
      ..writeByte(3)..write(obj.ayahText)
      ..writeByte(4)..write(obj.savedAt)
      ..writeByte(5)..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteAyahAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StudySessionAdapter extends TypeAdapter<StudySession> {
  @override
  final int typeId = 2;

  @override
  StudySession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudySession(
      surahNumber: fields[0] as int,
      surahName: fields[1] as String,
      startAyah: fields[2] as int,
      endAyah: fields[3] as int,
      repetitionsUsed: fields[4] as int,
      date: fields[5] as DateTime,
      durationMinutes: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StudySession obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.surahNumber)
      ..writeByte(1)..write(obj.surahName)
      ..writeByte(2)..write(obj.startAyah)
      ..writeByte(3)..write(obj.endAyah)
      ..writeByte(4)..write(obj.repetitionsUsed)
      ..writeByte(5)..write(obj.date)
      ..writeByte(6)..write(obj.durationMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 3;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      reciterId: fields[0] as String,
      repetitionsPerAyah: fields[1] as int,
      delayBetweenAyahs: fields[2] as double,
      playbackSpeed: fields[3] as double,
      arabicFontSize: fields[4] as double,
      showTranslation: fields[5] as bool,
      isDarkMode: fields[6] as bool,
      translationLanguage: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.reciterId)
      ..writeByte(1)..write(obj.repetitionsPerAyah)
      ..writeByte(2)..write(obj.delayBetweenAyahs)
      ..writeByte(3)..write(obj.playbackSpeed)
      ..writeByte(4)..write(obj.arabicFontSize)
      ..writeByte(5)..write(obj.showTranslation)
      ..writeByte(6)..write(obj.isDarkMode)
      ..writeByte(7)..write(obj.translationLanguage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
