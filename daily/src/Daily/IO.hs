{-# LANGUAGE OverloadedStrings #-}

module Daily.IO (runDailyM) where

import Daily (DailyM, DailyOp(..))

import Control.Monad.Free (iterM)
import System.IO (hPutStr, hFlush, stdout)
import System.Process.Typed (runProcess, runProcess_, proc, setWorkingDir)

dailyOpInterpret :: DailyOp (IO a) -> IO a
dailyOpInterpret (RunOSAScript script next) =
  runProcess_ (proc "osascript" ["-e", script]) >> next
dailyOpInterpret (MacOpen file next) =
  runProcess_ (proc "open" [file]) >> next
dailyOpInterpret (RunProgram maybeDir bin args next) =
  runProcess processSpec >>= next
  where
    processSpec = withWorkingDir $ proc bin args
    withWorkingDir = case maybeDir of
                       Just dir -> setWorkingDir dir
                       Nothing  -> id
dailyOpInterpret (WriteMessage msg next) =
  hPutStr stdout msg >> hFlush stdout >> next
dailyOpInterpret (WriteMessageLn msg next) =
  putStrLn msg >> next

runDailyM :: DailyM a -> IO a
runDailyM = iterM dailyOpInterpret
