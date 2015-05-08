@echo off
del /F /Q pkg\
cmd /c "gem uninstall cutedriver-qt-sut-plugin"
cmd /c "rake gem"
cmd /c "gem install pkg\cutedriver*.gem --LOCAL --no-ri --no-rdoc"
