#!/bin/bash

# Banner
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
echo " 	  ☠ SubReaper ☠ 		"
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

# التحقق من وجود الأدوات المطلوبة
for tool in findomain sublist3r assetfinder subfinder; do
    if ! command -v $tool &> /dev/null; then
        echo "Error: $tool is not installed. Please install it and try again."
        exit 1
    fi
done

# معالجة المعاملات
usage() {
    echo "Usage: subreaper -d domain.com -o output.txt"
    echo "Options:"
    echo "  -d    Target domain (required)"
    echo "  -o    Output file (required)"
    exit 1
}

# التحقق من المعاملات
while getopts "d:o:" opt; do
    case $opt in
        d)
            domain=$OPTARG
            # التحقق من صحة النطاق
            if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+$ ]]; then
                echo "Error: Invalid domain format"
                exit 1
            fi
            ;;
        o)
            output_file=$OPTARG
            # استخراج مسار المجلد من مسار الملف
            output_dir=$(dirname "$output_file")
            ;;
        *)
            usage
            ;;
    esac
done

# التحقق من وجود المعاملات المطلوبة
if [ -z "$domain" ] || [ -z "$output_file" ]; then
    usage
fi

# إنشاء المجلد إذا لم يكن موجوداً
mkdir -p "$output_dir"

echo -n "Loading: "
for i in {0..100..4}; do
    progress_bar $i
    sleep 0.1
done
echo -e "\n\nStarting the process...\n"

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
awk '!seen[$0]++' "$output_dir/all_subdomains.txt" > "$output_file"

# حذف الملفات المؤقتة
rm "$output_dir"/findomain.txt "$output_dir"/sublist3r.txt "$output_dir"/assetfinder.txt "$output_dir"/subfinder.txt
rm "$output_dir"/all_subdomains.txt

# عرض الإحصائيات النهائية
echo -e "\n\e[32mSubdomain discovery complete!\e[0m"
echo "Results saved in: $output_file"
echo "Total unique subdomains found: $(wc -l < "$output_file")"
