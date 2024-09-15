#!/bin/bash

# استقبال مدخل النطاق من المستخدم
read -p "Target_Domain: " domain

# استخراج النطاقات الفرعية باستخدام findomain

echo -e "\e[32;5mfindomain============================================================================>\e[0m"


findomain --target "$domain" --unique-output findomain.txt

sleep 1
# استخراج النطاقات الفرعية باستخدام github-subdomains.py
echo -e "\e[32;5msublist3r============================================================================>\e[0m"


sublist3r -d "$domain" -o sublist3r.txt

sleep 2.5
# استخراج النطاقات الفرعية باستخدام assetfinder
echo -e "\e[32;5massetfinder===========================================================================>\e[0m"

assetfinder --subs-only "$domain" | tee assetfinder.txt

sleep 2.5
# استخراج النطاقات الفرعية باستخدام subfinder
echo -e "\e[32;5msubfinder============================================================================>\e[0m"

subfinder -d "$domain" -o subfinder.txt

sleep 2.5
# دمج جميع النتائج في ملف واحد
cat findomain.txt sublist3r.txt assetfinder.txt subfinder.txt | sort -u > all-subdomains.txt

# حذف النطاقات المكررة
awk '!seen[$0]++' all-subdomains.txt > Sub_Done.txt

rm  findomain.txt sublist3r.txt assetfinder.txt subfinder.txt

rm all-subdomains.txt

echo "is done unique-subdomains.txt."
