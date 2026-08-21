#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
# SarVita Comprehensive Diagnostic
# Termux / Node.js / Railway / Vercel / Docker / Git
# ============================================================

set +e

PROJECT_ROOT="$(pwd)"
REPORT_DIR="$PROJECT_ROOT/diagnostic-report"
TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
REPORT="$REPORT_DIR/report-$TIMESTAMP.txt"

mkdir -p "$REPORT_DIR"

# ------------------------------------------------------------
# Colors
# ------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
WARN=0
FAIL=0
INFO=0

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    echo "[PASS] $1" >> "$REPORT"
    PASS=$((PASS + 1))
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "[WARN] $1" >> "$REPORT"
    WARN=$((WARN + 1))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    echo "[FAIL] $1" >> "$REPORT"
    FAIL=$((FAIL + 1))
}

info() {
    echo -e "${CYAN}[INFO]${NC} $1"
    echo "[INFO] $1" >> "$REPORT"
    INFO=$((INFO + 1))
}

section() {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
    echo
    {
        echo
        echo "============================================================"
        echo "$1"
        echo "============================================================"
        echo
    } >> "$REPORT"
}

run_cmd() {
    echo
    echo "\$ $*" >> "$REPORT"
    "$@" >> "$REPORT" 2>&1
    return $?
}

# ------------------------------------------------------------
# Header
# ------------------------------------------------------------

clear 2>/dev/null || true

echo "============================================================"
echo "        SarVita Comprehensive Diagnostic"
echo "============================================================"
echo
echo "Project : $PROJECT_ROOT"
echo "Date    : $(date)"
echo "Report  : $REPORT"
echo

cat > "$REPORT" <<EOF
SarVita Comprehensive Diagnostic Report
========================================

Project : $PROJECT_ROOT
Date    : $(date)
Device  : $(uname -a)

EOF

# ------------------------------------------------------------
# 1. Project root
# ------------------------------------------------------------

section "1. PROJECT ROOT"

if [ -f "package.json" ]; then
    pass "package.json موجود"
else
    fail "package.json غير موجود — يبدو أنك لست داخل مجلد المشروع"
fi

if [ -f "server.js" ]; then
    pass "server.js موجود"
else
    warn "server.js غير موجود"
fi

if [ -d "src" ]; then
    pass "src/ موجود"
else
    fail "src/ غير موجود"
fi

if [ -d "public" ]; then
    pass "public/ موجود"
else
    warn "public/ غير موجود"
fi

# ------------------------------------------------------------
# 2. Required tools
# ------------------------------------------------------------

section "2. TERMUX / SYSTEM TOOLS"

for cmd in git node npm; do
    if command -v "$cmd" >/dev/null 2>&1; then
        pass "$cmd موجود: $(command -v "$cmd")"
        {
            echo "$cmd version:"
            "$cmd" --version 2>&1
            echo
        } >> "$REPORT"
    else
        fail "$cmd غير مثبت"
    fi
done

if command -v curl >/dev/null 2>&1; then
    pass "curl موجود"
else
    warn "curl غير موجود — بعض اختبارات HTTP سيتم تخطيها"
fi

if command -v jq >/dev/null 2>&1; then
    pass "jq موجود"
else
    warn "jq غير موجود — سيتم استخدام parsing بديل"
fi

if command -v docker >/dev/null 2>&1; then
    pass "Docker موجود"
else
    info "Docker غير موجود في Termux — سيتم تخطي اختبار Docker"
fi

# ------------------------------------------------------------
# 3. Node.js version
# ------------------------------------------------------------

section "3. NODE.JS VERSION"

NODE_MAJOR=""

if command -v node >/dev/null 2>&1; then
    NODE_VERSION="$(node -v 2>/dev/null)"
    NODE_MAJOR="$(echo "$NODE_VERSION" | sed 's/^v//' | cut -d. -f1)"

    info "Node.js: $NODE_VERSION"

    if [ -n "$NODE_MAJOR" ] && [ "$NODE_MAJOR" -ge 20 ]; then
        pass "Node.js >= 20"
    else
        fail "Node.js أقل من الإصدار المطلوب >= 20"
    fi
fi

# ------------------------------------------------------------
# 4. package.json
# ------------------------------------------------------------

section "4. PACKAGE.JSON"

if [ -f "package.json" ]; then

    if command -v node >/dev/null 2>&1; then

        PACKAGE_NAME="$(node -p "try{require('./package.json').name}catch(e){''}" 2>/dev/null)"
        PACKAGE_VERSION="$(node -p "try{require('./package.json').version}catch(e){''}" 2>/dev/null)"
        ENGINE_NODE="$(node -p "try{require('./package.json').engines?.node || ''}catch(e){''}" 2>/dev/null)"

        info "Package: $PACKAGE_NAME"
        info "Version: $PACKAGE_VERSION"
        info "Node engine: $ENGINE_NODE"

        for script in start build test; do
            EXISTS="$(node -p "try{Boolean(require('./package.json').scripts?.['$script'])}catch(e){false}" 2>/dev/null)"

            if [ "$EXISTS" = "true" ]; then
                pass "npm script موجود: $script"
            else
                warn "npm script غير موجود: $script"
            fi
        done

        START_PROD="$(node -p "try{require('./package.json').scripts?.['start:production'] || ''}catch(e){''}" 2>/dev/null)"

        if [ -n "$START_PROD" ]; then
            info "start:production = $START_PROD"

            if echo "$START_PROD" | grep -q '\${PORT:-8000}'; then
                warn "start:production يستخدم \${PORT:-8000} shell expansion"
            fi
        else
            warn "start:production غير موجود"
        fi

        BUILD_SCRIPT="$(node -p "try{require('./package.json').scripts?.build || ''}catch(e){''}" 2>/dev/null)"
        START_SCRIPT="$(node -p "try{require('./package.json').scripts?.start || ''}catch(e){''}" 2>/dev/null)"

        info "build = $BUILD_SCRIPT"
        info "start = $START_SCRIPT"
    fi
else
    fail "لا يمكن فحص package.json"
fi

# ------------------------------------------------------------
# 5. package-lock / dependencies
# ------------------------------------------------------------

section "5. NPM DEPENDENCIES"

if [ -f "package-lock.json" ]; then
    pass "package-lock.json موجود"
else
    warn "package-lock.json غير موجود"
fi

if [ -d "node_modules" ]; then
    pass "node_modules موجود"
else
    warn "node_modules غير موجود — سيتم محاولة npm ci لاحقًا"
fi

if [ -f "package.json" ]; then

    echo "Dependencies containing native/WASM-related packages:" >> "$REPORT"

    grep -Ein \
        'tiktoken|wasm|sharp|canvas|sqlite|better-sqlite|node-gyp|onnx|esbuild' \
        package.json >> "$REPORT" 2>/dev/null || true

fi

# ------------------------------------------------------------
# 6. Required project files
# ------------------------------------------------------------

section "6. DEPLOYMENT FILES"

FILES=(
    "Dockerfile"
    "docker-entrypoint.sh"
    "railway.json"
    "vercel.json"
    "server.js"
    "config.yaml"
    ".gitignore"
    "README.md"
)

for file in "${FILES[@]}"; do
    if [ -e "$file" ]; then
        pass "$file موجود"
    else
        warn "$file غير موجود"
    fi
done

# ------------------------------------------------------------
# 7. Railway configuration
# ------------------------------------------------------------

section "7. RAILWAY CONFIGURATION"

if [ -f "railway.json" ]; then

    info "railway.json:"
    cat railway.json >> "$REPORT"

    echo >> "$REPORT"

    if grep -qi '"buildCommand"' railway.json; then
        pass "Railway buildCommand موجود"
    else
        warn "Railway buildCommand غير موجود"
    fi

    if grep -qi '"startCommand"' railway.json; then
        pass "Railway startCommand موجود"
    else
        warn "Railway startCommand غير موجود"
    fi

    if grep -qi 'healthcheckPath' railway.json; then
        pass "Railway healthcheckPath موجود"
    else
        warn "healthcheckPath غير موجود"
    fi

    if grep -qi 'PORT' railway.json; then
        info "PORT مستخدم داخل railway.json"
    else
        info "PORT غير مذكور صراحة داخل railway.json — Railway عادة يوفره تلقائيًا"
    fi

else
    fail "railway.json غير موجود"
fi

# ------------------------------------------------------------
# 8. Vercel configuration
# ------------------------------------------------------------

section "8. VERCEL CONFIGURATION"

if [ -f "vercel.json" ]; then

    pass "vercel.json موجود"

    echo "vercel.json:" >> "$REPORT"
    cat vercel.json >> "$REPORT"
    echo >> "$REPORT"

    if grep -q 'api/index.js' vercel.json; then
        pass "api/index.js مرتبط بـ Vercel"
    else
        warn "api/index.js غير ظاهر داخل vercel.json"
    fi

    if grep -q 'public' vercel.json; then
        pass "public مرتبط بإعدادات Vercel"
    else
        warn "public غير ظاهر داخل vercel.json"
    fi

else
    warn "vercel.json غير موجود"
fi

# ------------------------------------------------------------
# 9. Docker
# ------------------------------------------------------------

section "9. DOCKERFILE"

if [ -f "Dockerfile" ]; then

    if grep -Eiq 'node:.*(20|22|23|24|lts)' Dockerfile; then
        pass "Dockerfile يستخدم Node حديث"
    else
        warn "لم يتم التأكد أن Dockerfile يستخدم Node >=20"
    fi

    if grep -q 'EXPOSE' Dockerfile; then
        pass "EXPOSE موجود في Dockerfile"
        grep -n 'EXPOSE' Dockerfile >> "$REPORT"
    else
        warn "EXPOSE غير موجود"
    fi

    if grep -Eq 'CMD|ENTRYPOINT' Dockerfile; then
        pass "CMD/ENTRYPOINT موجود"
    else
        fail "لا يوجد CMD أو ENTRYPOINT في Dockerfile"
    fi

    echo "Dockerfile:" >> "$REPORT"
    cat Dockerfile >> "$REPORT"

else
    warn "Dockerfile غير موجود"
fi

# ------------------------------------------------------------
# 10. Environment variables
# ------------------------------------------------------------

section "10. ENVIRONMENT VARIABLES"

info "Searching environment variable usage..."

grep -Rho \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude-dir=.next \
    --exclude='*.lock' \
    -E 'process\.env\.[A-Za-z_][A-Za-z0-9_]*' \
    . 2>/dev/null \
    | sed 's/.*process\.env\.//' \
    | sort -u \
    | tee -a "$REPORT" >/tmp/sarvita_env_vars.txt

echo

if [ -s /tmp/sarvita_env_vars.txt ]; then
    while IFS= read -r VAR; do
        info "ENV detected: $VAR"
    done < /tmp/sarvita_env_vars.txt
else
    warn "لم يتم العثور على process.env variables"
fi

rm -f /tmp/sarvita_env_vars.txt

# ------------------------------------------------------------
# 11. Important environment variables
# ------------------------------------------------------------

section "11. IMPORTANT ENV CHECK"

IMPORTANT_VARS=(
    "NODE_ENV"
    "PORT"
    "DATA_ROOT"
    "SESSION_SECRET"
    "COOKIE_SECRET"
    "PUID"
    "PGID"
    "VERCEL"
)

for VAR in "${IMPORTANT_VARS[@]}"; do

    if grep -Rqs \
        --exclude-dir=node_modules \
        --exclude-dir=.git \
        --exclude-dir=.next \
        "process.env.$VAR" \
        . 2>/dev/null; then

        if [ -n "${!VAR:-}" ]; then
            info "$VAR موجود في البيئة الحالية"
        else
            warn "$VAR مستخدم في المشروع لكنه غير موجود في Termux environment"
        fi
    fi

done

# ------------------------------------------------------------
# 12. Security / secrets
# ------------------------------------------------------------

section "12. SECURITY / SECRET CHECK"

if [ -f ".env" ]; then
    warn ".env موجود — تأكد أنه غير مرفوع إلى Git"
else
    pass ".env غير موجود في جذر المشروع"
fi

if git ls-files 2>/dev/null | grep -Eq '(^|/)\.env($|\.)'; then
    fail ".env يبدو أنه tracked داخل Git"
else
    pass ".env غير ظاهر ضمن Git tracked files"
fi

if [ -f ".gitignore" ]; then

    if grep -qxF '.env' .gitignore || grep -qE '(^|/)\.env' .gitignore; then
        pass ".env مذكور في .gitignore"
    else
        warn ".env غير ظاهر في .gitignore"
    fi
fi

# Search suspicious secret names without printing values
grep -Rni \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.lock' \
    -E 'SESSION_SECRET|COOKIE_SECRET|API_KEY|SECRET_KEY|PASSWORD|TOKEN' \
    . 2>/dev/null \
    | head -100 >> "$REPORT"

# ------------------------------------------------------------
# 13. DATA_ROOT / storage
# ------------------------------------------------------------

section "13. DATA_ROOT / STORAGE"

grep -Rni \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    -E 'DATA_ROOT|node-persist|initUserStorage|getCookieSecret' \
    . 2>/dev/null \
    | head -200 >> "$REPORT"

if grep -Rqs \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    'DATA_ROOT' . 2>/dev/null; then
    pass "DATA_ROOT مستخدم في المشروع"
else
    info "لم يتم العثور على DATA_ROOT"
fi

if grep -Rqs \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    'node-persist' . 2>/dev/null; then
    warn "node-persist موجود — يجب الانتباه للتخزين في Railway/Vercel"
fi

# ------------------------------------------------------------
# 14. PORT / listen / host
# ------------------------------------------------------------

section "14. PORT / HOST / LISTEN"

grep -Rni \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.lock' \
    -E 'process\.env\.PORT|--port|listen\(|0\.0\.0\.0|localhost' \
    . 2>/dev/null \
    | head -250 >> "$REPORT"

if grep -Rqs \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    'process.env.PORT' . 2>/dev/null; then
    pass "المشروع يقرأ process.env.PORT"
else
    warn "لم يتم العثور على process.env.PORT"
fi

if grep -Rqs \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    '0.0.0.0' . 2>/dev/null; then
    pass "0.0.0.0 موجود"
else
    warn "لم يتم العثور على 0.0.0.0 — قد تكون هناك مشكلة على Railway"
fi

# ------------------------------------------------------------
# 15. Whitelist / proxy / IP
# ------------------------------------------------------------

section "15. WHITELIST / IP / RAILWAY PROXY"

echo "Searching whitelist and proxy code..." >> "$REPORT"

grep -Rni \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.lock' \
    -E 'whitelist|allowlist|blocked connection|remoteAddress|x-forwarded-for|x-real-ip|trust proxy|proxy' \
    . 2>/dev/null \
    | head -400 >> "$REPORT"

if grep -Rqs \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    -Ei 'whitelist|allowlist' . 2>/dev/null; then

    warn "وجد نظام whitelist/allowlist داخل المشروع"

    if [ -f "config.yaml" ]; then
        if grep -niE 'whitelist|allowlist' config.yaml >> "$REPORT" 2>/dev/null; then
            info "تم العثور على whitelist داخل config.yaml"
        fi
    fi
else
    info "لم يتم العثور على whitelist واضح"
fi

# ------------------------------------------------------------
# 16. CSRF / sessions
# ------------------------------------------------------------

section "16. CSRF / SESSION / COOKIE"

grep -Rni \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.lock' \
    -E 'csrf|cookie-session|session|sameSite|httpOnly|secure:' \
    . 2>/dev/null \
    | head -500 >> "$REPORT"

if grep -Rqs \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    "'serverless'" \
    . 2>/dev/null; then

    warn "تم العثور على token/قيمة serverless ثابتة — راجع CSRF"
fi

if grep -Rqs \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    'cookieSession' \
    . 2>/dev/null; then

    pass "cookie-session مستخدم"
else
    info "لم يتم العثور على cookieSession"
fi

# ------------------------------------------------------------
# 17. API endpoints
# ------------------------------------------------------------

section "17. API ENDPOINTS"

if [ -d "api" ]; then

    find api -type f -maxdepth 4 2>/dev/null | sort | tee -a "$REPORT"

    if [ -f "api/ping.js" ]; then
        pass "api/ping.js موجود"
    else
        warn "api/ping.js غير موجود"
    fi

    if [ -f "api/index.js" ]; then
        pass "api/index.js موجود"
    else
        warn "api/index.js غير موجود"
    fi

else
    warn "مجلد api غير موجود"
fi

# Search settings endpoints
SETTINGS_MATCHES="$(grep -Rni \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    -E 'settings/get|/settings|settings.*get' \
    src api public 2>/dev/null | head -100)"

if [ -n "$SETTINGS_MATCHES" ]; then
    info "تم العثور على مراجع settings"
    echo "$SETTINGS_MATCHES" >> "$REPORT"
else
    warn "لم يتم العثور على endpoint واضح لـ settings"
fi

# ------------------------------------------------------------
# 18. Video interface
# ------------------------------------------------------------

section "18. VIDEO / FRONTEND"

VIDEO_MATCHES="$(grep -Rni \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    -E 'catbox|\.mp4|<video|video/mp4|playsinline|preload|poster' \
    public src 2>/dev/null | head -300)"

if [ -n "$VIDEO_MATCHES" ]; then
    pass "تم العثور على مراجع فيديو"
    echo "$VIDEO_MATCHES" >> "$REPORT"
else
    warn "لم يتم العثور على مرجع واضح للفيديو داخل public/src"
fi

if [ -d "public" ]; then

    info "Public files:"
    find public -maxdepth 3 -type f 2>/dev/null \
        | sort \
        | head -300 >> "$REPORT"

fi

# ------------------------------------------------------------
# 19. JavaScript syntax checks
# ------------------------------------------------------------

section "19. JAVASCRIPT SYNTAX"

if command -v node >/dev/null 2>&1; then

    JS_COUNT=0
    JS_FAIL=0

    while IFS= read -r file; do

        JS_COUNT=$((JS_COUNT + 1))

        node --check "$file" >/tmp/sarvita_js_check.log 2>&1

        if [ $? -ne 0 ]; then
            JS_FAIL=$((JS_FAIL + 1))

            fail "JavaScript syntax error: $file"

            {
                echo
                echo "===== SYNTAX ERROR: $file ====="
                cat /tmp/sarvita_js_check.log
            } >> "$REPORT"
        fi

    done < <(
        find . \
            -type f \
            -name "*.js" \
            -not -path "./node_modules/*" \
            -not -path "./.git/*" \
            2>/dev/null
    )

    if [ "$JS_FAIL" -eq 0 ]; then
        pass "فحص JavaScript syntax نجح ($JS_COUNT files)"
    else
        fail "$JS_FAIL من أصل $JS_COUNT ملفات JavaScript تحتوي أخطاء syntax"
    fi

    rm -f /tmp/sarvita_js_check.log
fi

# ------------------------------------------------------------
# 20. JSON validation
# ------------------------------------------------------------

section "20. JSON CONFIGURATION"

if command -v node >/dev/null 2>&1; then

    for file in \
        package.json \
        railway.json \
        vercel.json \
        tsconfig.json \
        jsconfig.json; do

        if [ -f "$file" ]; then

            node -e "
                const fs=require('fs');
                const f='$file';
                try {
                    JSON.parse(fs.readFileSync(f,'utf8'));
                    console.log('VALID');
                } catch(e) {
                    console.error(e.message);
                    process.exit(1);
                }
            " >/tmp/sarvita_json.log 2>&1

            if [ $? -eq 0 ]; then
                pass "$file JSON صالح"
            else
                fail "$file JSON غير صالح"
                cat /tmp/sarvita_json.log >> "$REPORT"
            fi
        fi

    done

    rm -f /tmp/sarvita_json.log
fi

# ------------------------------------------------------------
# 21. YAML basic check
# ------------------------------------------------------------

section "21. YAML CONFIGURATION"

if [ -f "config.yaml" ]; then

    info "config.yaml موجود"

    if command -v ruby >/dev/null 2>&1; then

        ruby -e "require 'yaml'; YAML.load_file('config.yaml'); puts 'VALID YAML'" \
            >/tmp/sarvita_yaml.log 2>&1

        if [ $?
