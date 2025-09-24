# modules/fonts/gw-patcher.nix
{ pkgs, lib, ... }:

{
  # Function to patch any font with the GW glyph
  lib.gwFontPatcher = {
    makePatchedFont = { baseFont, fontName ? null, glyphUnicode ? "0x2AF8" }: 
      let
        derivedName = if fontName != null then fontName else "${baseFont.pname or baseFont.name}-gw-patched";
      in
      pkgs.stdenv.mkDerivation {
        pname = derivedName;
        version = "${baseFont.version or "1.0.0"}-gw-patched";

        src = baseFont;

        nativeBuildInputs = [ pkgs.fontforge ];

        buildPhase = ''
          # Find and copy font files
          find ${baseFont} -name "*.ttf" -o -name "*.otf" | while read font; do
            cp "$font" .
          done
          
          # Copy glyph from this module directory
          cp ${./uni2AF8_GW.svg} uni2AF8_GW.svg
          
          # Create FontForge script
          cat > patch.pe << EOF
          #!/usr/bin/fontforge
          Open(\$1)
          Select(${glyphUnicode})
          Clear()
          Import("uni2AF8_GW.svg")
          Generate(\$1)
          Close()
          EOF
          
          # Patch all font files
          for font in *.ttf *.otf; do
            if [[ -f "$font" ]]; then
              echo "Patching $font with GW glyph at ${glyphUnicode}..."
              fontforge -script patch.pe "$font" || echo "Warning: Failed to patch $font"
            fi
          done
        '';

        installPhase = ''
          mkdir -p $out/share/fonts/truetype $out/share/fonts/opentype
          
          if ls *.ttf &> /dev/null; then
            cp *.ttf $out/share/fonts/truetype/
          fi
          
          if ls *.otf &> /dev/null; then
            cp *.otf $out/share/fonts/opentype/
          fi
        '';

        meta = {
          description = "Font patched with custom GW glyph";
          platforms = lib.platforms.all;
        };
      };

    # Pre-made popular fonts
    fonts = {
      cascadia-code = self.makePatchedFont {
        baseFont = pkgs.cascadia-code;
        fontName = "cascadia-code-gw-patched";
      };
      
      fira-code = self.makePatchedFont {
        baseFont = pkgs.fira-code;
        fontName = "fira-code-gw-patched";
      };
      
      jetbrains-mono = self.makePatchedFont {
        baseFont = pkgs.jetbrains-mono;
        fontName = "jetbrains-mono-gw-patched";
      };
    };
  };
}