import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theming/packs/catppuccin_theme_pack.dart';
import 'package:lazurite/src/app/theming/packs/nord_theme_pack.dart';
import 'package:lazurite/src/app/theming/packs/one_dark_theme_pack.dart';
import 'package:lazurite/src/app/theming/packs/oxocarbon_theme_pack.dart';
import 'package:lazurite/src/app/theming/packs/rose_pine_theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_variant.dart';

/// Validates that a [ThemeVariant] has all required M3 ColorScheme roles
/// and maintains proper visual hierarchy.
///
/// These tests act as "role lint" checks to ensure theme packs don't
/// accidentally flatten the visual hierarchy or omit critical roles.
void main() {
  group('ThemeVariant Role Lint', () {
    void validateVariantRoles(ThemeVariant variant, String name) {
      final cs = variant.derivedScheme;

      group(name, () {
        group('required surface container roles present', () {
          test('surface is defined', () {
            expect(cs.surface, isNotNull);
          });

          test('surfaceDim is defined', () {
            expect(cs.surfaceDim, isNotNull);
          });

          test('surfaceBright is defined', () {
            expect(cs.surfaceBright, isNotNull);
          });

          test('surfaceContainerLowest is defined', () {
            expect(cs.surfaceContainerLowest, isNotNull);
          });

          test('surfaceContainerLow is defined', () {
            expect(cs.surfaceContainerLow, isNotNull);
          });

          test('surfaceContainer is defined', () {
            expect(cs.surfaceContainer, isNotNull);
          });

          test('surfaceContainerHigh is defined', () {
            expect(cs.surfaceContainerHigh, isNotNull);
          });

          test('surfaceContainerHighest is defined', () {
            expect(cs.surfaceContainerHighest, isNotNull);
          });
        });

        group('required on-surface roles present', () {
          test('onSurface is defined', () {
            expect(cs.onSurface, isNotNull);
          });

          test('onSurfaceVariant is defined', () {
            expect(cs.onSurfaceVariant, isNotNull);
          });
        });

        group('required outline roles present', () {
          test('outline is defined', () {
            expect(cs.outline, isNotNull);
          });

          test('outlineVariant is defined', () {
            expect(cs.outlineVariant, isNotNull);
          });
        });

        group('required accent roles present', () {
          test('primary is defined', () {
            expect(cs.primary, isNotNull);
          });

          test('onPrimary is defined', () {
            expect(cs.onPrimary, isNotNull);
          });

          test('secondary is defined', () {
            expect(cs.secondary, isNotNull);
          });

          test('onSecondary is defined', () {
            expect(cs.onSecondary, isNotNull);
          });

          test('secondaryContainer is defined', () {
            expect(cs.secondaryContainer, isNotNull);
          });

          test('onSecondaryContainer is defined', () {
            expect(cs.onSecondaryContainer, isNotNull);
          });

          test('error is defined', () {
            expect(cs.error, isNotNull);
          });

          test('onError is defined', () {
            expect(cs.onError, isNotNull);
          });
        });

        group('hierarchy integrity checks', () {
          test('surface != surfaceContainerLow (cards should stand out)', () {
            expect(
              cs.surface,
              isNot(equals(cs.surfaceContainerLow)),
              reason: 'Cards on surfaceContainerLow need to be distinct from surface',
            );
          });

          test('surfaceContainerLow != surfaceContainerHigh (elevation step)', () {
            expect(
              cs.surfaceContainerLow,
              isNot(equals(cs.surfaceContainerHigh)),
              reason: 'Container levels must provide visible elevation steps',
            );
          });

          test('onSurface != onSurfaceVariant (emphasis differentiation)', () {
            expect(
              cs.onSurface,
              isNot(equals(cs.onSurfaceVariant)),
              reason: 'Primary and secondary text must have different emphasis',
            );
          });

          test('outline != outlineVariant (boundary emphasis levels)', () {
            expect(
              cs.outline,
              isNot(equals(cs.outlineVariant)),
              reason: 'Strong and subtle boundaries must differ',
            );
          });

          test('primary != secondary (accent differentiation)', () {
            expect(
              cs.primary,
              isNot(equals(cs.secondary)),
              reason: 'Primary and secondary accents must be distinct',
            );
          });

          test('surfaceDim != surfaceBright (brightness range)', () {
            expect(
              cs.surfaceDim,
              isNot(equals(cs.surfaceBright)),
              reason: 'Surface brightness range must be meaningful',
            );
          });
        });

        group('container ladder ordering (for dark theme)', () {
          if (variant.isDark) {
            test('surfaceContainerLowest is darker than surfaceContainerHighest', () {
              final lowestLuminance = cs.surfaceContainerLowest.computeLuminance();
              final highestLuminance = cs.surfaceContainerHighest.computeLuminance();

              expect(
                lowestLuminance,
                lessThan(highestLuminance),
                reason: 'In dark themes, higher containers should be brighter',
              );
            });
          }
        });

        group('container ladder ordering (for light theme)', () {
          if (variant.isLight) {
            test('surfaceContainerLowest is lighter than surfaceContainerHighest', () {
              final lowestLuminance = cs.surfaceContainerLowest.computeLuminance();
              final highestLuminance = cs.surfaceContainerHighest.computeLuminance();

              expect(
                lowestLuminance,
                greaterThan(highestLuminance),
                reason: 'In light themes, higher containers should be darker',
              );
            });
          }
        });
      });
    }

    validateVariantRoles(oxocarbonDarkVariant, 'Oxocarbon Dark');
    validateVariantRoles(oxocarbonLightVariant, 'Oxocarbon Light');

    validateVariantRoles(catppuccinLatteVariant, 'Catppuccin Latte');
    validateVariantRoles(catppuccinFrappeVariant, 'Catppuccin Frappé');
    validateVariantRoles(catppuccinMacchiatoVariant, 'Catppuccin Macchiato');
    validateVariantRoles(catppuccinMochaVariant, 'Catppuccin Mocha');

    validateVariantRoles(nordDarkVariant, 'Nord Dark');
    validateVariantRoles(nordLightVariant, 'Nord Light');

    validateVariantRoles(rosePineMainVariant, 'Rosé Pine Main');
    validateVariantRoles(rosePineMoonVariant, 'Rosé Pine Moon');
    validateVariantRoles(rosePineDawnVariant, 'Rosé Pine Dawn');

    validateVariantRoles(oneDarkVariant, 'One Dark');
    validateVariantRoles(oneLightVariant, 'One Light');
  });

  group('OxocarbonPack', () {
    test('pack has both dark and light variants', () {
      expect(oxocarbonPack.darkVariant, isNotNull);
      expect(oxocarbonPack.lightVariant, isNotNull);
    });

    test('pack has correct metadata', () {
      expect(oxocarbonPack.id, 'oxocarbon');
      expect(oxocarbonPack.name, 'Oxocarbon');
      expect(oxocarbonPack.author, 'IBM');
    });

    test('dark variant has correct id', () {
      expect(oxocarbonDarkVariant.id, 'oxocarbon-dark');
    });

    test('light variant has correct id', () {
      expect(oxocarbonLightVariant.id, 'oxocarbon-light');
    });

    test('variants have correct brightness', () {
      expect(oxocarbonDarkVariant.brightness, Brightness.dark);
      expect(oxocarbonLightVariant.brightness, Brightness.light);
    });

    group('palette values', () {
      test('primary is BlueSky blue', () {
        expect(oxocarbonDarkVariant.derivedScheme.primary, const Color(0xFF0085FF));
        expect(oxocarbonLightVariant.derivedScheme.primary, const Color(0xFF0085FF));
      });

      test('error is pink/magenta', () {
        expect(oxocarbonDarkVariant.derivedScheme.error, const Color(0xFFEE5396));
      });

      test('dark surface is oxocarbon dark gray', () {
        expect(oxocarbonDarkVariant.derivedScheme.surface, const Color(0xFF1A1A1A));
      });

      test('light surface is oxocarbon light gray', () {
        expect(oxocarbonLightVariant.derivedScheme.surface, const Color(0xFFF2F4F8));
      });
    });
  });

  group('CatppuccinPack', () {
    test('pack has all 4 flavors', () {
      expect(catppuccinPack.variants, hasLength(4));
    });

    test('pack has correct metadata', () {
      expect(catppuccinPack.id, 'catppuccin');
      expect(catppuccinPack.name, 'Catppuccin');
      expect(catppuccinPack.author, 'Catppuccin');
    });

    test('latte is light variant', () {
      expect(catppuccinLatteVariant.brightness, Brightness.light);
    });

    test('dark variants are dark', () {
      expect(catppuccinFrappeVariant.brightness, Brightness.dark);
      expect(catppuccinMacchiatoVariant.brightness, Brightness.dark);
      expect(catppuccinMochaVariant.brightness, Brightness.dark);
    });

    test('variants have correct ids', () {
      expect(catppuccinLatteVariant.id, 'catppuccin-latte');
      expect(catppuccinFrappeVariant.id, 'catppuccin-frappe');
      expect(catppuccinMacchiatoVariant.id, 'catppuccin-macchiato');
      expect(catppuccinMochaVariant.id, 'catppuccin-mocha');
    });
  });

  group('NordPack', () {
    test('pack has dark and light variants', () {
      expect(nordPack.darkVariant, isNotNull);
      expect(nordPack.lightVariant, isNotNull);
    });

    test('pack has correct metadata', () {
      expect(nordPack.id, 'nord');
      expect(nordPack.name, 'Nord');
      expect(nordPack.author, 'Arctic Ice Studio');
    });

    test('variants have correct brightness', () {
      expect(nordDarkVariant.brightness, Brightness.dark);
      expect(nordLightVariant.brightness, Brightness.light);
    });
  });

  group('RosePinePack', () {
    test('pack has 3 variants', () {
      expect(rosePinePack.variants, hasLength(3));
    });

    test('pack has correct metadata', () {
      expect(rosePinePack.id, 'rose-pine');
      expect(rosePinePack.name, 'Rosé Pine');
      expect(rosePinePack.author, 'Rosé Pine');
    });

    test('dawn is light variant', () {
      expect(rosePineDawnVariant.brightness, Brightness.light);
    });

    test('main and moon are dark variants', () {
      expect(rosePineMainVariant.brightness, Brightness.dark);
      expect(rosePineMoonVariant.brightness, Brightness.dark);
    });
  });

  group('OneDarkPack', () {
    test('pack has dark and light variants', () {
      expect(oneDarkPack.darkVariant, isNotNull);
      expect(oneDarkPack.lightVariant, isNotNull);
    });

    test('pack has correct metadata', () {
      expect(oneDarkPack.id, 'one-dark');
      expect(oneDarkPack.name, 'One Dark');
      expect(oneDarkPack.author, 'Atom');
    });

    test('variants have correct brightness', () {
      expect(oneDarkVariant.brightness, Brightness.dark);
      expect(oneLightVariant.brightness, Brightness.light);
    });
  });
}
