-- | Compile with: dist/build/fay/fay -autorun examples/canvaswater.hs

{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE NoImplicitPrelude #-}

-- | A demonstration of Fay using the canvas element to display a
-- simple effect.

module CanvasWater (main) where

import Language.Fay.FFI
import Language.Fay.Prelude

-- | Main entry point.
main :: Fay ()
main = do
  img <- newImage
  addEventListener img "load" (start img) False
  setSrc img "haskell.png"

-- | Start the animation.
start :: Image -> Fay ()
start img = do
  canvas <- getElementById "can"
  context <- getContext canvas "2d"
  drawImage context img 0 0
  step <- newRef (0 :: Double)
  setInterval (animate context img step) 30

-- | Animate the water effect.
animate :: Context -> Image -> Ref Double -> Fay ()
animate context img step = do
  stepn <- readRef step
  setFillStyle context "rgb(255,255,255)"
  forM_ [0..imgHeight] $ \i ->
    drawImageSpecific context img
                      0 0
                      imgWidth imgHeight
                      (sin(3*(stepn+i/20.0))*(i/2.0)) (140+i)
                      imgWidth imgHeight
  writeRef step (stepn + 0.05)

imgHeight = 140
imgWidth = 200

--------------------------------------------------------------------------------
-- Elements

class Eventable a

-- | A DOM element.
data Element
instance Foreign Element
instance Eventable Element

-- | Add an event listener to an element.
addEventListener :: (Foreign a,Eventable a) => a -> String -> Fay () -> Bool -> Fay ()
addEventListener = foreignPropFay "addEventListener" FayNone

-- | Get an element by its ID.
getElementById :: String -> Fay Element
getElementById = foreignFay "document.getElementById" FayNone

--------------------------------------------------------------------------------
-- Images

data Image
instance Foreign Image
instance Eventable Image

-- | Make a new image.
newImage :: Fay Image
newImage = foreignFay "new Image" FayNone

-- | Make a new image.
setSrc :: Image -> String -> Fay ()
setSrc = foreignSetProp "src"

--------------------------------------------------------------------------------
-- Canvas

-- | A canvas context.
data Context
instance Foreign Context

-- | Get an element by its ID.
getContext :: Element -> String -> Fay Context
getContext = foreignPropFay "getContext" FayNone

-- | Draw an image onto a canvas rendering context.
drawImage :: Context -> Image -> Double -> Double -> Fay ()
drawImage = foreignPropFay "drawImage" FayNone

-- | Draw an image onto a canvas rendering context.
--
--   Nine arguments: the element, source (x,y) coordinates, source width and 
--   height (for cropping), destination (x,y) coordinates, and destination width 
--   and height (resize).
--
--   context.drawImage(img_elem, sx, sy, sw, sh, dx, dy, dw, dh);
drawImageSpecific :: Context -> Image
                  -> Double -> Double -> Double -> Double -> Double -> Double -> Double -> Double
                  -> Fay ()
drawImageSpecific = foreignPropFay "drawImage" FayNone

-- | Set the fill style.
setFillStyle :: Context -> String -> Fay ()
setFillStyle = foreignSetProp "fillStyle"

-- | Set the fill style.
setFillRect :: Context -> Double -> Double -> Double -> Double -> Fay ()
setFillRect = foreignPropFay "fillRect" FayNone

--------------------------------------------------------------------------------
-- Ref

-- | A mutable reference like IORef.
data Ref a
instance Foreign a => Foreign (Ref a)

-- | Make a new mutable reference.
newRef :: Foreign a => a -> Fay (Ref a)
newRef = foreignFay "new Fay$$Ref" FayNone

-- | Replace the value in the mutable reference.
writeRef :: Foreign a => Ref a -> a -> Fay ()
writeRef = foreignFay "Fay$$writeRef" FayNone

-- | Get the referred value from the mutable value.
readRef :: Foreign a => Ref a -> Fay a
readRef = foreignFay "Fay$$readRef" FayNone

--------------------------------------------------------------------------------
-- Misc

-- | Alert using window.alert.
alert :: Foreign a => a -> Fay ()
alert = foreignFay "window.alert" FayNone

-- | Alert using window.alert.
print :: Double -> Fay ()
print = foreignFay "console.log" FayNone

-- | Alert using window.alert.
log :: String -> Fay ()
log = foreignFay "console.log" FayNone

-- | Alert using window.alert.
sin :: Double -> Double
sin = foreignPure "Math.sin" FayNone

-- | Alert using window.alert.
setInterval :: Fay () -> Double -> Fay ()
setInterval = foreignFay "window.setInterval" FayNone
