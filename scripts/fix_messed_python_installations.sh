pip freeze | cut -d '=' -f 1 >installed_packages.txt
diff -u minimal_requirements.txt installed_packages.txt | grep '^-' | cut -c 2- | xargs pip uninstall -y
rm installed_packages.txt
