@echo off
del /F /Q pkg\
cmd /c "gem uninstall testability-driver-qt-sut-plugin"
cmd /c "rake gem"
cmd /c "gem install pkg\testability-driver*.gem --LOCAL"
