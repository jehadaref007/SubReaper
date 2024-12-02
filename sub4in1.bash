#!/bin/bash

echo "
⠀⠀⠀⠀⠀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣰⡾⠛⠛⠉⠻⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢀⣿⠀⠀⠀⠀⠀⠈⠻⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠸⣧⡀⠀⠀⠀⠀⠀⠀⠈⠻⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠈⠻⣦⡀⠀⠀⠀⠀⠀⢸⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠈⠻⣦⣀⣀⣀⣠⣾⠷⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣠⣤⡤⠀
⠀⠀⠀⠀⠀⠀⠈⠛⠉⠉⠙⣷⣴⠟⠛⠛⣷⣄⠀⠀⠀⠀⢿⡟⠛⠉⠉⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣦⡾⠋⢙⣷⣄⠀⠀⢸⡇⠀⢠⡶⣶⣦⣤⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣶⡟⠉⣹⣷⣄⠘⣿⢀⣿⠁⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⡏⢀⣿⢷⣿⣾⠃⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣁⣴⠟⣿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⡿⠷⢶⣾⣿⣷⣴⠟⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣨⣿⣾⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠙⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠀⠀⠀⠈⠛⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀
"
echo " ================================"
echo " 	  ☠ RootKit ☠ 		"
echo " ================================"
echo ""

progress_bar() {
    local progress=$1
    local total=100
    local max_width=30
    
    local filled=$((progress * max_width / total))
    local empty=$((max_width - filled))
    
    printf "\r["
    printf "%0.s█" $(seq 1 $filled)
    printf "%0.s " $(seq 1 $empty)
    printf "] $progress%%"
    
    if [ $progress -eq 100 ]; then
        printf "\r["
        printf "%0.s█" $(seq 1 $max_width)
        printf "] $progress%%"
    fi
}

echo -n "Loading: "
for i in {0..100..4}; do
    progress_bar $i
    sleep 0.1
done
echo -e "\n\nStarting the process...\n"

# التحقق من وجود الأدوات المطلوبة
for tool in findomain sublist3r assetfinder subfinder; do
    if ! command -v $tool &> /dev/null; then
        echo "Error: $tool is not installed. Please install it and try again."
        exit 1
    fi
done

# استقبال النطاق من المستخدم والتحقق من صحته
read -p "🔎 Enter the Domain Name:" domain
if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+$ ]]; then
    echo "Invalid domain format. Please enter a valid domain."
    exit 1
fi

# استقبال مسار حفظ النتائج واسم الملف
read -p "Enter output directory (e.g., /path/to/directory):" output_dir
read -p "Enter output file name (e.g., results.txt):" output_file

# التحقق من أن المجلد موجود، إذا لم يكن موجودًا سيتم إنشاؤه
mkdir -p "$output_dir"

# تشغيل الأدوات واستخراج النطاقات الفرعية
echo -e "\n\e[32mRunning findomain...\e[0m"
findomain --target "$domain" --unique-output "$output_dir/findomain.txt"

echo -e "\n\e[32mRunning sublist3r...\e[0m"
sublist3r -d "$domain" -o "$output_dir/sublist3r.txt"

echo -e "\n\e[32mRunning assetfinder...\e[0m"
assetfinder --subs-only "$domain" > "$output_dir/assetfinder.txt"

echo -e "\n\e[32mRunning subfinder...\e[0m"
subfinder -d "$domain" -o "$output_dir/subfinder.txt"

# دمج النتائج وإزالة التكرارات
echo -e "\n\e[32mMerging and cleaning results...\e[0m"
cat "$output_dir"/*.txt | sort -u > "$output_dir/all_subdomains.txt"

# حفظ النطاقات الفريدة فقط
unique_file="$output_dir/$output_file"
awk '!seen[$0]++' "$output_dir/all_subdomains.txt" > "$unique_file"

# حذف الملفات المؤقتة
rm "$output_dir"/findomain.txt "$output_dir"/sublist3r.txt "$output_dir"/assetfinder.txt "$output_dir"/subfinder.txt
rm "$output_dir"/all_subdomains.txt

# عرض الإحصائيات النهائية
echo -e "\n\e[32mSubdomain discovery complete!\e[0m"
echo "Results saved in: $unique_file"
echo "Total unique subdomains found: $(wc -l < "$unique_file")"
