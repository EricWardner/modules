# Save this as: nixos/peripherals/audio.nix
{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.peripherals;
in
{
  config = mkIf cfg.dellXpsEqualizer.enable {
    # https://gist.github.com/alexVinarskis/77d55a0a0f4150576ba77e5f4241d512
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      wireplumber.enable = true;

      extraConfig.pipewire."99-dell-xps-equalizer" = {
        "context.modules" = [
          {
            name = "libpipewire-module-filter-chain";
            args = {
              "node.description" = "Internal Speakers Equalizer Sink";
              "media.name" = "Internal Speakers Equalizer Sink";
              "filter.graph" = {
                nodes = [
                  {
                    type = "builtin";
                    name = "eq_band_1";
                    label = "bq_peaking";
                    control = {
                      "Freq" = 119.0;
                      "Q" = 1.5;
                      "Gain" = 11.0;
                    };
                  }
                  {
                    type = "builtin";
                    name = "eq_band_2";
                    label = "bq_peaking";
                    control = {
                      "Freq" = 238.0;
                      "Q" = 1.5;
                      "Gain" = 2.0;
                    };
                  }
                  {
                    type = "builtin";
                    name = "eq_band_3";
                    label = "bq_peaking";
                    control = {
                      "Freq" = 475.0;
                      "Q" = 1.5;
                      "Gain" = -11.0;
                    };
                  }
                  {
                    type = "builtin";
                    name = "eq_band_4";
                    label = "bq_peaking";
                    control = {
                      "Freq" = 947.0;
                      "Q" = 1.5;
                      "Gain" = -11.0;
                    };
                  }
                  {
                    type = "builtin";
                    name = "eq_band_5";
                    label = "bq_peaking";
                    control = {
                      "Freq" = 1890.0;
                      "Q" = 1.5;
                      "Gain" = -2.0;
                    };
                  }
                  {
                    type = "builtin";
                    name = "eq_band_6";
                    label = "bq_peaking";
                    control = {
                      "Freq" = 3771.0;
                      "Q" = 1.5;
                      "Gain" = 2.0;
                    };
                  }
                  {
                    type = "builtin";
                    name = "eq_band_7";
                    label = "bq_peaking";
                    control = {
                      "Freq" = 7524.0;
                      "Q" = 1.5;
                      "Gain" = 9.0;
                    };
                  }
                  {
                    type = "builtin";
                    name = "eq_band_8";
                    label = "bq_peaking";
                    control = {
                      "Freq" = 15012.0;
                      "Q" = 1.5;
                      "Gain" = 10.0;
                    };
                  }
                ];
                links = [
                  {
                    output = "eq_band_1:Out";
                    input = "eq_band_2:In";
                  }
                  {
                    output = "eq_band_2:Out";
                    input = "eq_band_3:In";
                  }
                  {
                    output = "eq_band_3:Out";
                    input = "eq_band_4:In";
                  }
                  {
                    output = "eq_band_4:Out";
                    input = "eq_band_5:In";
                  }
                  {
                    output = "eq_band_5:Out";
                    input = "eq_band_6:In";
                  }
                  {
                    output = "eq_band_6:Out";
                    input = "eq_band_7:In";
                  }
                  {
                    output = "eq_band_7:Out";
                    input = "eq_band_8:In";
                  }
                ];
              };
              "audio.channels" = 2;
              "audio.position" = [
                "FL"
                "FR"
              ];
              "capture.props" = {
                "node.name" = "internal_speaker";
                "media.class" = "Audio/Sink";
              };
              "playback.props" = {
                "node.name" = "internal_speaker_equalizer_output";
                "node.passive" = true;
                "node.target" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink";
              };
            };
          }
        ];
      };
    };
  };
}