#!/bin/bash

# Banner
echo -e "\e[31m
██████╗  ██████╗  ██████╗ ████████╗██╗  ██╗██╗████████╗
██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██║ ██╔╝██║╚══██╔══╝
██████╔╝██║   ██║██║   ██║   ██║   █████╔╝ ██║   ██║   
██╔══██╗██║   ██║██║   ██║   ██║   ██╔═██╗ ██║   ██║   
██║  ██║╚██████╔╝╚██████╔╝   ██║   ██║  ██╗██║   ██║   
╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚═╝   ╚═╝   
\e[0m"
echo -e "\e[31m =================================================\e[0m"
echo -e "\e[31m ===============SubReaper v1.0====================\e[0m"
echo -e "\e[31m =================================================\e[0m"

# دالة للتحقق من وجود الأدوات
check_tools() {
    local missing_tools=()
    local all_installed=true
    
    echo -e "\n\e[34m[*] Checking required tools...\e[0m"
    
    for tool in findomain sublist3r assetfinder subfinder; do
        if ! command -v $tool &> /dev/null; then
            echo -e "\e[31m[-] $tool is not installed\e[0m"
            missing_tools+=($tool)
            all_installed=false
        else
            echo -e "\e[32m[+] $tool is installed\e[0m"
        fi
    done
    
    if [ "$all_installed" = false ]; then
        echo -e "\n\e[31m[!] Missing tools: ${missing_tools[*]}\e[0m"
        echo -e "\e[33m[*] Please install the missing tools and try again\e[0m"
        return 1
    else
        echo -e "\n\e[32m[✓] All required tools are installed!\e[0m"
        return 0
    fi
}

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

# معالجة المعاملات
usage() {
    echo "Usage: subreaper [-C] -d domain.com -o output.txt"
    echo "Options:"
    echo "  -C    Check for required tools and exit"
    echo "  -d    Target domain (required)"
    echo "  -o    Output file (required)"
    exit 1
}

# التحقق من المعاملات
check_only=false
while getopts "Cd:o:" opt; do
    case $opt in
        C)
            check_only=true
            ;;
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

# إذا كان المستخدم يريد فقط التحقق من الأدوات
if [ "$check_only" = true ]; then
    check_tools
    exit $?
fi

# التحقق من وجود المعاملات المطلوبة
if [ -z "$domain" ] || [ -z "$output_file" ]; then
    usage
fi

# التحقق من الأدوات قبل البدء
if ! check_tools; then
    exit 1
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
