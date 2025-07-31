import 'dicebear_avatar_generator.dart';

class AvatarPresets {
  static DiceBearAvatarGenerator friendly({required String seed}) {
    return DiceBearAvatarGenerator(seed: seed, style: 'avataaars')
        .setSize(128)
        .setTop(['shortFlat'])
        .setHairColor(['b58143'])
        .setEyes(['happy'])
        .setMouth(['smile'])
        .setClothing(['shirtCrewNeck'])
        .setClothesColor(['65c9ff'])
        .setSkinColor(['ffdbb4']);
  }

  static DiceBearAvatarGenerator techie({required String seed}) {
    return DiceBearAvatarGenerator(seed: seed, style: 'avataaars')
        .setSize(128)
        .setTop(['frizzle'])
        .setHairColor(['262e33'])
        .setEyes(['eyeRoll'])
        .setMouth(['serious'])
        .setAccessories(['prescription01'])
        .setClothing(['hoodie'])
        .setClothesColor(['3c4f5c']);
  }

  static DiceBearAvatarGenerator cool({required String seed}) {
    return DiceBearAvatarGenerator(seed: seed, style: 'avataaars')
        .setSize(128)
        .setTop(['hat'])
        .setHairColor(['ff5c5c'])
        .setEyes(['squint'])
        .setMouth(['twinkle'])
        .setClothing(['graphicShirt'])
        .setClothesColor(['e6e6e6'])
        .setAccessories(['wayfarers']);
  }

  static DiceBearAvatarGenerator nerd({required String seed}) {
    return DiceBearAvatarGenerator(seed: seed, style: 'avataaars')
        .setSize(128)
        .setAccessories(['prescription02'])
        .setTop(['bob'])
        .setEyes(['default'])
        .setMouth(['serious'])
        .setClothing(['blazerAndSweater'])
        .setClothesColor(['262e33']);
  }

  static DiceBearAvatarGenerator mysterious({required String seed}) {
    return DiceBearAvatarGenerator(seed: seed, style: 'avataaars')
        .setSize(128)
        .setTop(['hijab'])
        .setEyes(['side'])
        .setMouth(['disbelief'])
        .setClothing(['collarAndSweater']);
  }

  static DiceBearAvatarGenerator goth({required String seed}) {
    return DiceBearAvatarGenerator(seed: seed, style: 'avataaars')
        .setSize(128)
        .setTop(['shavedSides'])
        .setHairColor(['262e33'])
        .setClothesColor(['000000'])
        .setMouth(['serious'])
        .setEyes(['xDizzy']);
  }

  static DiceBearAvatarGenerator casual({required String seed}) {
    return DiceBearAvatarGenerator(seed: seed, style: 'avataaars')
        .setSize(128)
        .setTop(['shortCurly'])
        .setMouth(['smile'])
        .setEyes(['wink'])
        .setClothing(['shirtScoopNeck']);
  }

  static DiceBearAvatarGenerator professional({required String seed}) {
    return DiceBearAvatarGenerator(seed: seed, style: 'avataaars')
        .setSize(128)
        .setTop(['theCaesar'])
        .setClothing(['blazerAndShirt'])
        .setAccessories(['round'])
        .setMouth(['default']);
  }

  static DiceBearAvatarGenerator party({required String seed}) {
    return DiceBearAvatarGenerator(seed: seed, style: 'avataaars')
        .setSize(128)
        .setTop(['frida'])
        .setMouth(['smile'])
        .setEyes(['happy'])
        .setAccessories(['sunglasses'])
        .setClothing(['shirtVNeck'])
        .setClothesColor(['ff5c5c']);
  }

  static DiceBearAvatarGenerator colorfulRoundedAvatar({required String seed}) {
    return DiceBearAvatarGenerator(seed: seed, style: 'thumbs')
        .setSize(128)
        .setBackgroundColor(['b6e3f4', 'c0aede', 'd1d4f9', 'ffd5dc', 'ffdfbf'])
        .setBackgroundType(['gradientLinear', 'solid'])
        .setEyes([
          'variant01',
          'variant02',
          'variant03',
          'variant09',
          'variant12',
        ])
        .setMouth([
          'variant01',
          'variant02',
          'variant03',
          'variant05',
          'variant09',
        ])
        .setShape(['circle', 'rounded'])
        .setShapeColor(['69d2e7']);
  }
}
