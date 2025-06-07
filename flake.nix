{
  description = "C++ development environment with Windows cross-compilation";
  
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system} = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # build tools
            cmake
            ninja
            
            # native compilation
            gcc

            # graphics/window system dependencies
            pkg-config
            wayland
            wayland-protocols
            wayland-scanner
            libxkbcommon
            libffi

            #opengl
            libGL
            libGLU
            
            # X11 dependencies (in case you want X11 support too)
            xorg.libX11
            xorg.libXcursor
            xorg.libXi
            xorg.libXinerama
            xorg.libXrandr
            
            # development tools
            clang-tools
            gdb
          ];
          
          shellHook = ''
            echo "🚀 C++ Development Environment Ready!"
            echo ""
            echo "📦 Native Linux build:"
            echo "   mkdir -p build/linux && cd build/linux"
            echo "   cmake ../.. && make"
            echo ""
            echo "🪟 Windows cross-compile:"
            echo "   nix develop .#windows"
            echo "   mkdir -p build/windows && cd build/windows"
            echo "   cmake ../.. && cmake --build ."
            echo ""
            echo "🔧 Native compiler: gcc/g++"

            # runtime library paths for graphics libraries
            export LD_LIBRARY_PATH="${pkgs.wayland}/lib:${pkgs.libxkbcommon}/lib:${pkgs.libGL}/lib:$LD_LIBRARY_PATH"
          '';
        };
        
        windows = pkgs.mkShell {
          packages = with pkgs; [
            cmake
            ninja
            pkgsCross.mingwW64.stdenv.cc
            pkgsCross.mingwW64.buildPackages.cmake
            clang-tools
          ];
          
          shellHook = ''
            echo "🪟 Windows Cross-Compilation Environment"
            
            export CMAKE_TOOLCHAIN_FILE=${./toolchain-mingw.cmake}
            export CC=x86_64-w64-mingw32-gcc
            export CXX=x86_64-w64-mingw32-g++
            
            echo "💡 Build with:"
            echo "   mkdir -p build/windows && cd build/windows"
            echo "   cmake ../.. && cmake --build ."
            echo ""
            echo "🔧 Cross compiler: x86_64-w64-mingw32-gcc/g++"
          '';
        };
      };
    };
}
