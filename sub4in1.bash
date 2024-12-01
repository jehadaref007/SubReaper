#!/bin/bash

# التحقق من وجود الأدوات المطلوبة
for tool in findomain sublist3r assetfinder subfinder; do
    command -v $tool > /dev/null || { echo "$tool is not installed. Please install it and try again."; exit 1; }
done

# استقبال النطاق من المستخدم والتحقق من صحته
read -p "Target_Domain: " domain
if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+$ ]]; then
    echo "Invalid domain. Please try again."
    exit 1
fi

# دليل العمل
output_dir="subdomain_results"
mkdir -p "$output_dir"

# وظيفة لمعالجة النتائج من كل أداة
process_tool() {
    local tool_name=$1
    local output_file=$2
    echo -e "\e[32;5mRunning $tool_name ===========================================================================>\e[0m"
    $3 > "$output_file" &
}

# تشغيل الأدوات بشكل متوازٍ
process_tool "findomain" "$output_dir/findomain.txt" "findomain --target $domain --unique-output -"
process_tool "sublist3r" "$output_dir/sublist3r.txt" "sublist3r -d $domain -o -"
process_tool "assetfinder" "$output_dir/assetfinder.txt" "assetfinder --subs-only $domain"
process_tool "subfinder" "$output_dir/subfinder.txt" "subfinder -d $domain -o -"

# الانتظار حتى تنتهي جميع العمليات
wait

# دمج النتائج وإزالة التكرارات
echo -e "\e[32;5mMerging and cleaning results =================================================================>\e[0m"
cat "$output_dir"/*.txt | sort -u > "$output_dir/all-subdomains.txt"

# إزالة التكرارات بشكل إضافي وتنسيق النتائج النهائية
awk '!seen[$0]++' "$output_dir/all-subdomains.txt" > "$output_dir/unique-subdomains.txt"

# حذف الملفات المؤقتة
rm "$output_dir"/*.txt
mv "$output_dir/unique-subdomains.txt" "$output_dir/final_subdomains.txt"

# عرض الإحصائيات
echo "========================================="
echo "Subdomain discovery complete!"
echo "Final results saved in: $output_dir/final_subdomains.txt"
echo "Total unique subdomains found: $(wc -l < "$output_dir/final_subdomains.txt")"
echo "========================================="
