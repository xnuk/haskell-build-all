module Main where

import Distribution.Package
import Distribution.PackageDescription
import Distribution.Version
import Distribution.PackageDescription.PrettyPrint (showGenericPackageDescription)
import Distribution.Compiler (CompilerFlavor(GHC))
import Language.Haskell.Extension (Language(Haskell2010))
import Control.Monad (ap)
import Data.List (isPrefixOf)



blacklist :: String -> Bool
blacklist str = any ($ str)
    [ is "Win32"
    , pre "Win32-"

    , is "bindings-GLFW"
    , is "GLFW-b"

    , is "bindings-libzip"
    , is "LibZip"

    , is "hidapi"
    , is "hmpfr"
    , is "hs-GeoIP"

--    , is "X11"
--    , pre "X11-"
--    , is "xmonad"
--    , pre "xmonad-"
--    , is "Xauth"

    , is "cryptohash" -- DEPRECATED
    , pre "cryptohash-"
    , is "executable-hash"
    ]
    where is = (==)
          pre = isPrefixOf

deps :: [String] -> [Dependency]
deps = map (\p -> Dependency (PackageName p) anyVersion) . filter (not . blacklist)

exef :: BuildInfo -> Executable
exef = Executable "build-all-exe" "Main.hs"

buildinfo :: [Dependency] -> BuildInfo
buildinfo x = emptyBuildInfo
    { hsSourceDirs = ["app"]
    , options = [(GHC,
        [ "-threaded"
        , "-rtsopts"
        , "-with-rtsopts=-N"
        ]
      )]
    , defaultLanguage = Just Haskell2010
    , targetBuildDepends = Dependency (PackageName "base") (withinVersion (Version [4, 9] [])) : x
    }

descf :: Executable -> PackageDescription
descf exe = emptyPackageDescription
    { package = PackageIdentifier (PackageName "build-all") (Version [0, 1, 0, 0] [])
    , buildType = Just Simple
    , specVersionRaw = Left (Version [1, 12] [])
    , executables = [exe]
    }

gn :: Executable -> PackageDescription -> GenericPackageDescription
gn exe desc = GenericPackageDescription
    { packageDescription = desc
    , genPackageFlags = []
    , condLibrary = Nothing
    , condExecutables =
        [ ("build-all-exe", CondNode
            { condTreeData = exe
            , condTreeConstraints = []
            , condTreeComponents = []
            }
          )
        ]
    , condTestSuites = []
    , condBenchmarks = []
    }

main :: IO ()
main = getLine >>= putStrLn . showGenericPackageDescription . ap gn descf . exef . buildinfo . deps . words

