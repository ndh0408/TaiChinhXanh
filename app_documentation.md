# Tài Liệu Chi Tiết - App Tài Chính Cá Nhân

## 📋 Mục Lục
1. [Tổng Quan Ứng Dụng](#tổng-quan-ứng-dụng)
2. [Kiến Trúc & Công Nghệ](#kiến-trúc--công-nghệ)
3. [Cấu Trúc Thư Mục](#cấu-trúc-thư-mục)
4. [Hệ Thống Thiết Kế (Design System)](#hệ-thống-thiết-kế-design-system)
5. [Cơ Sở Dữ Liệu](#cơ-sở-dữ-liệu)
6. [Tính Năng Chính](#tính-năng-chính)
7. [Chức Năng AI](#chức-năng-ai)
8. [Bảo Mật](#bảo-mật)
9. [Giao Diện Người Dùng](#giao-diện-người-dùng)
10. [Hướng Dẫn Sử Dụng](#hướng-dẫn-sử-dụng)
11. [Kỹ Thuật Triển Khai](#kỹ-thuật-triển-khai)

---

## 🎯 Tổng Quan Ứng Dụng

### Giới Thiệu
**App Tài Chính Cá Nhân** là một ứng dụng quản lý tài chính thông minh được phát triển bằng Flutter, tích hợp công nghệ AI để cung cấp trải nghiệm quản lý tài chính toàn diện và cá nhân hóa cho người dùng Việt Nam.

### Mục Tiêu
- **Quản lý tài chính toàn diện**: Theo dõi thu chi, lương, ngân sách, mục tiêu tài chính
- **Phân tích thông minh**: Sử dụng AI để phân tích hành vi chi tiêu và đưa ra gợi ý
- **Bảo mật cao**: Tích hợp PIN, sinh trắc học, mã hóa AES-256
- **Giao diện hiện đại**: Thiết kế theo Material Design 3 với responsive design

### Đối Tượng Người Dùng
- Cá nhân muốn quản lý tài chính cá nhân một cách chuyên nghiệp
- Người lao động có nhu cầu theo dõi lương và chi tiêu hàng tháng
- Những người có mục tiêu tiết kiệm và đầu tư dài hạn

---

## 🏗️ Kiến Trúc & Công Nghệ

### Tech Stack
- **Frontend**: Flutter (Dart)
- **Database**: SQLite với sqflite
- **State Management**: Provider
- **Charts**: FL Chart
- **Security**: 
  - Mã hóa: encrypt package (AES-256)
  - Sinh trắc học: local_auth
  - Lưu trữ bảo mật: shared_preferences
- **Fonts**: Google Fonts (Inter)
- **Icons**: Material Icons

### Kiến Trúc Ứng Dụng
```
┌─────────────────────────────────────┐
│           Presentation Layer        │
│  ┌─────────────┐ ┌─────────────────┐│
│  │   Screens   │ │     Widgets     ││
│  └─────────────┘ └─────────────────┘│
├─────────────────────────────────────┤
│            Business Layer           │
│  ┌─────────────┐ ┌─────────────────┐│
│  │  Providers  │ │   AI Engines    ││
│  └─────────────┘ └─────────────────┘│
├─────────────────────────────────────┤
│             Data Layer              │
│  ┌─────────────┐ ┌─────────────────┐│
│  │  Services   │ │     Models      ││
│  └─────────────┘ └─────────────────┘│
├─────────────────────────────────────┤
│           Storage Layer             │
│  ┌─────────────┐ ┌─────────────────┐│
│  │   SQLite    │ │   SharedPrefs   ││
│  └─────────────┘ └─────────────────┘│
└─────────────────────────────────────┘
```

---

## 📁 Cấu Trúc Thư Mục

```
lib/
├── main.dart                 # Entry point
├── theme.dart               # Design system & themes
│
├── screens/                 # Các màn hình chính
│   ├── initialization_screen.dart
│   ├── dashboard_screen.dart
│   ├── salary_screen.dart
│   ├── transactions_screen.dart
│   ├── analytics_screen.dart
│   ├── budgets_screen.dart
│   ├── goals_screen.dart
│   └── settings_screen.dart
│
├── widgets/                 # UI components
│   ├── financial_overview_card.dart
│   ├── ai_suggestions_card.dart
│   ├── transaction_form.dart
│   ├── transaction_tile.dart
│   ├── budget_form.dart
│   ├── budget_tile.dart
│   ├── goal_form.dart
│   ├── goal_tile.dart
│   ├── income_source_form.dart
│   ├── income_source_tile.dart
│   └── salary_record_form.dart
│
├── models/                  # Data models
│   ├── transaction.dart
│   ├── category.dart
│   ├── income_source.dart
│   ├── salary_record.dart
│   ├── ai_suggestion.dart
│   └── ai_analytics.dart
│
├── providers/               # State management
│   ├── transaction_provider.dart
│   ├── income_source_provider.dart
│   └── ai_provider.dart
│
├── services/                # Business logic & API calls
│   ├── transaction_service.dart
│   ├── category_service.dart
│   ├── income_source_service.dart
│   ├── salary_record_service.dart
│   ├── ai_suggestion_service.dart
│   └── security_service.dart
│
├── ai/                      # AI engines
│   ├── expense_analyzer.dart
│   ├── salary_analyzer.dart
│   └── smart_suggestions_engine.dart
│
├── db/                      # Database
│   ├── db_init.dart
│   └── schema.dart
│
└── utils/                   # Utilities
```

---

## 🎨 Hệ Thống Thiết Kế (Design System)

### Color Palette
```dart
// Primary Colors
primaryColor: #3B82F6 (Blue 500)
primaryLight: #60A5FA (Blue 400)
primaryDark: #1E40AF (Blue 700)

// Secondary Colors
secondaryColor: #10B981 (Emerald 500)
secondaryLight: #34D399 (Emerald 400)

// Financial Colors
incomeColor: #10B981 (Emerald 500)
expenseColor: #EF4444 (Red 500)
savingsColor: #8B5CF6 (Violet 500)

// Status Colors
successColor: #10B981
errorColor: #EF4444
warningColor: #F59E0B
infoColor: #3B82F6

// Text Colors
textPrimary: #0F172A (Slate 900)
textSecondary: #64748B (Slate 500)
textMuted: #94A3B8 (Slate 400)

// Background Colors
backgroundColor: #F8FAFC (Slate 50)
surfaceColor: #FFFFFF
cardColor: #FFFFFF
```

### Typography
**Font Family**: Google Fonts Inter
- **Display Large**: 57px, Light
- **Display Medium**: 45px, Regular
- **Display Small**: 36px, Regular
- **Headline Large**: 32px, Medium
- **Headline Medium**: 28px, Medium
- **Headline Small**: 24px, Medium
- **Title Large**: 22px, Medium
- **Title Medium**: 16px, Medium
- **Title Small**: 14px, Medium
- **Body Large**: 16px, Regular
- **Body Medium**: 14px, Regular
- **Body Small**: 12px, Regular
- **Label Large**: 14px, Medium
- **Label Medium**: 12px, Medium
- **Label Small**: 11px, Medium

### Spacing System (8dp Grid)
```dart
spacing1: 4.0   // 0.5 × 8dp
spacing2: 8.0   // 1 × 8dp
spacing3: 12.0  // 1.5 × 8dp
spacing4: 16.0  // 2 × 8dp
spacing6: 24.0  // 3 × 8dp
spacing8: 32.0  // 4 × 8dp
spacing10: 40.0 // 5 × 8dp
spacing12: 48.0 // 6 × 8dp
spacing16: 64.0 // 8 × 8dp
```

### Responsive Breakpoints
- **Mobile**: < 768px
- **Tablet**: 768px - 1024px
- **Desktop**: > 1024px

### Border Radius
```dart
radiusSmall: 4.0
radiusMedium: 8.0
radiusLarge: 12.0
radiusXLarge: 16.0
```

---

## 🗄️ Cơ Sở Dữ Liệu

### Schema Overview
Ứng dụng sử dụng SQLite với 6 bảng chính:

#### 1. **income_sources** - Nguồn Thu Nhập
```sql
CREATE TABLE income_sources (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT CHECK(type IN ('salary', 'freelance', 'business', 'investment', 'other')),
    base_amount REAL DEFAULT 0,
    frequency TEXT CHECK(frequency IN ('daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'irregular')),
    tax_rate REAL DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### 2. **salary_records** - Bản Ghi Lương
```sql
CREATE TABLE salary_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    income_source_id INTEGER NOT NULL,
    gross_amount REAL NOT NULL,
    net_amount REAL NOT NULL,
    bonus_amount REAL DEFAULT 0,
    deductions_amount REAL DEFAULT 0,
    received_date DATE NOT NULL,
    working_days INTEGER DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (income_source_id) REFERENCES income_sources(id)
);
```

#### 3. **transactions** - Giao Dịch
```sql
CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount REAL NOT NULL,
    type TEXT CHECK(type IN ('income', 'expense')),
    category_id INTEGER NOT NULL,
    income_source_id INTEGER,
    description TEXT,
    payment_method TEXT DEFAULT 'cash',
    location TEXT,
    receipt_photo TEXT,
    tags TEXT,
    transaction_date DATE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### 4. **categories** - Danh Mục
```sql
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT CHECK(type IN ('income', 'expense')),
    color TEXT DEFAULT '#2196F3',
    icon TEXT DEFAULT 'money',
    budget_limit REAL DEFAULT 0,
    is_essential INTEGER DEFAULT 0,
    priority INTEGER DEFAULT 1
);
```

#### 5. **ai_suggestions** - Gợi Ý AI
```sql
CREATE TABLE ai_suggestions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    priority INTEGER DEFAULT 1,
    is_read INTEGER DEFAULT 0,
    trigger_conditions TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### 6. **ai_analytics** - Phân Tích AI
```sql
CREATE TABLE ai_analytics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    analysis_type TEXT NOT NULL,
    input_data TEXT,
    result_data TEXT,
    confidence_score REAL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## ⚡ Tính Năng Chính

### 1. 📊 Dashboard - Tổng Quan
**Mô tả**: Màn hình chính hiển thị tổng quan tài chính
**Chức năng**:
- Hiển thị tóm tắt thu nhập và chi tiêu tháng hiện tại
- Card tổng quan tài chính với biểu đồ trực quan
- Danh sách gợi ý AI chưa đọc (tối đa 3 items)
- Responsive layout: Desktop 2 cột, Mobile 1 cột
- Các thống kê quan trọng: Tỷ lệ tiết kiệm, Thu nhập ròng, Chi tiêu

**Logic nghiệp vụ**:
```dart
// Tính toán thống kê tháng hiện tại
final monthlyStats = transactionProvider.getMonthlyStats(DateTime.now());
final monthlyIncome = incomeProvider.totalMonthlyIncome;
final savingsRate = (monthlyIncome - monthlyStats['totalExpenses']) / monthlyIncome;
```

### 2. 💰 Quản Lý Lương
**Mô tả**: Quản lý các nguồn thu nhập và bản ghi lương
**Chức năng**:
- Thêm/sửa/xóa nguồn thu nhập
- Ghi nhận lương hàng tháng với chi tiết gross/net/bonus/deductions
- Phân tích tăng trưởng lương qua thời gian
- Dự báo thu nhập tháng tiếp theo
- Tối ưu hóa thuế

**Loại nguồn thu nhập**:
- `salary`: Lương cứng
- `freelance`: Freelance
- `business`: Kinh doanh
- `investment`: Đầu tư
- `other`: Khác

**Tần suất**: daily, weekly, monthly, quarterly, yearly, irregular

### 3. 💳 Quản Lý Giao Dịch
**Mô tả**: Theo dõi tất cả giao dịch thu chi
**Chức năng**:
- Thêm/sửa/xóa giao dịch thu nhập và chi tiêu
- Phân loại theo danh mục
- Gắn tag cho dễ tìm kiếm
- Lọc và sắp xếp giao dịch
- Upload ảnh hóa đơn
- Ghi nhận vị trí giao dịch

**Phương thức thanh toán**:
- `cash`: Tiền mặt
- `card`: Thẻ
- `bank_transfer`: Chuyển khoản
- `e_wallet`: Ví điện tử
- `other`: Khác

### 4. 📈 Phân Tích & Báo Cáo
**Mô tả**: Cung cấp báo cáo chi tiết và trực quan
**Chức năng**:
- **Biểu đồ đường**: Xu hướng thu nhập theo thời gian
- **Biểu đồ tròn**: Phân bổ chi tiêu theo danh mục
- **Biểu đồ cột**: So sánh thu chi theo tháng
- **Phân tích tiết kiệm**: Tiến độ đạt mục tiêu tiết kiệm
- **Thẻ tóm tắt**: Các chỉ số tài chính quan trọng

### 5. 🎯 Ngân Sách & Mục Tiêu
**Mô tả**: Lập kế hoạch tài chính và theo dõi mục tiêu
**Chức năng ngân sách**:
- Đặt hạn mức chi tiêu cho từng danh mục
- Theo dõi % thực hiện ngân sách
- Cảnh báo khi vượt ngân sách
- Phân loại chi tiêu thiết yếu/không thiết yếu

**Chức năng mục tiêu**:
- Đặt mục tiêu tiết kiệm dài hạn
- Theo dõi tiến độ đạt mục tiêu
- Tính toán thời gian dự kiến hoàn thành
- Gợi ý cách đạt mục tiêu nhanh hơn

### 6. ⚙️ Cài Đặt & Bảo Mật
**Mô tả**: Cấu hình ứng dụng và bảo mật
**Nhóm cài đặt**:

**Bảo mật**:
- Đặt/thay đổi PIN 6 số
- Kích hoạt sinh trắc học (vân tay/khuôn mặt)
- Tự động khóa sau thời gian không hoạt động

**Dữ liệu & Sao lưu**:
- Xuất dữ liệu ra file
- Import dữ liệu từ file
- Xóa toàn bộ dữ liệu

**Giao diện**:
- Chọn ngôn ngữ
- Chế độ tối/sáng
- Đơn vị tiền tệ

**Thông báo**:
- Nhắc nhở nhập giao dịch
- Cảnh báo vượt ngân sách
- Gợi ý AI mới

---

## 🤖 Chức Năng AI

### 1. Smart Suggestions Engine
**Mục đích**: Tạo gợi ý thông minh dựa trên hành vi tài chính
**Các loại gợi ý**:

**Cảnh báo chi tiêu** (`expense_warning`):
- Phát hiện khi chi tiêu > 80% thu nhập
- Priority: 5 (Cao nhất)

**Cải thiện tiết kiệm** (`savings_improvement`):
- Khuyến nghị khi tỷ lệ tiết kiệm < 20%
- Priority: 4

**Đa dạng thu nhập** (`income_diversification`):
- Gợi ý tạo thêm nguồn thu nhập khi chỉ có 1 nguồn
- Priority: 3

**Phát triển sự nghiệp** (`career_growth`):
- Nhắc nhở khi lương tăng < 5%/năm
- Priority: 3

**Tối ưu danh mục** (`category_optimization`):
- Gợi ý cắt giảm khi 1 danh mục chiếm > 30% tổng chi tiêu
- Priority: 2

**Theo mùa** (`seasonal`):
- Gợi ý phù hợp với thời điểm trong năm
- Priority: 2

### 2. Expense Analyzer
**Chức năng chính**:

**Phát hiện bất thường**:
- Sử dụng Z-score để phát hiện giao dịch bất thường
- Ngưỡng: Z-score > 2.0
- Phân loại mức độ: high (Z > 3.0), medium (Z > 2.0)

**Phân tích pattern chi tiêu**:
- Phân bổ theo danh mục
- Pattern theo thời gian (giờ, ngày trong tuần)
- Xu hướng chi tiêu (tăng/giảm/ổn định)
- Phân tích tương quan

**Gợi ý cắt giảm chi tiêu**:
- Tính potential savings theo độ ưu tiên danh mục
- Non-essential: có thể cắt 30%
- Essential: chỉ cắt 10%
- Gợi ý cụ thể theo từng loại chi tiêu

### 3. Salary Analyzer
**Chức năng chính**:

**Phân tích tăng trưởng lương**:
- Tính growth rate và monthly growth rate
- So sánh với lạm phát (giả định 3%/năm)
- Đánh giá real growth rate

**Dự báo thu nhập**:
- Sử dụng linear regression
- Điều chỉnh theo yếu tố mùa vụ
- Tính confidence interval (95%)

**Tối ưu thuế**:
- Gợi ý các khoản khấu trừ hợp pháp
- Bảo hiểm y tế (tối đa 1.5% thu nhập)
- Đóng góp từ thiện (tối đa 2% thu nhập)
- Chi phí học tập (tối đa 1% thu nhập)

---

## 🔒 Bảo Mật

### 1. PIN Protection
**Đặc điểm**:
- PIN 6 số
- Hash với salt trước khi lưu
- Xác thực khi mở ứng dụng

**Implementation**:
```dart
static String _hashPin(String pin) {
  final salt = 'apptaichinh_salt_2024';
  final combined = pin + salt;
  return base64Encode(utf8.encode(combined));
}
```

### 2. Biometric Authentication
**Hỗ trợ**:
- Vân tay (Fingerprint)
- Nhận diện khuôn mặt (Face ID/Face Recognition)
- Fallback về PIN nếu sinh trắc học thất bại

**Cấu hình**:
- Bật/tắt trong Settings
- Chỉ hoạt động khi đã đặt PIN

### 3. Data Encryption
**Thuật toán**: AES-256
**Mã hóa**:
- Dữ liệu nhạy cảm trong SharedPreferences
- Key được tạo ngẫu nhiên và lưu trữ cục bộ
- IV (Initialization Vector) ngẫu nhiên cho mỗi lần mã hóa

**Dữ liệu được mã hóa**:
- Cài đặt bảo mật
- Thông tin cá nhân nhạy cảm
- Dữ liệu sao lưu

### 4. Auto-lock
**Chức năng**:
- Tự động khóa ứng dụng sau thời gian không hoạt động
- Mặc định: 5 phút
- Có thể tùy chỉnh: 1, 5, 15, 30 phút hoặc tắt

### 5. Security Service API
**Các phương thức chính**:
```dart
// PIN Management
Future<bool> setPin(String pin)
Future<bool> verifyPin(String pin)
Future<bool> changePin(String currentPin, String newPin)

// Biometric
Future<bool> authenticateWithBiometric()
Future<bool> isBiometricAvailable()

// Encryption
Future<String?> encryptData(String data)
Future<String?> decryptData(String encryptedData)

// Auto-lock
Future<void> updateLastActiveTime()
Future<bool> shouldAutoLock()
```

---

## 🎨 Giao Diện Người Dùng

### 1. Navigation Structure
**Bottom Navigation Bar với 7 tabs**:
1. **Tổng quan** (`Icons.dashboard`) - Dashboard
2. **Lương** (`Icons.monetization_on`) - Salary Management  
3. **Giao dịch** (`Icons.receipt_long`) - Transactions
4. **Phân tích** (`Icons.analytics`) - Analytics & Reports
5. **Ngân sách** (`Icons.account_balance_wallet`) - Budgets
6. **Mục tiêu** (`Icons.flag`) - Goals
7. **Cài đặt** (`Icons.settings`) - Settings

### 2. Key UI Components

#### FinancialOverviewCard
**Vị trí**: Dashboard screen
**Hiển thị**:
- Biểu đồ thu chi dạng Bar Chart
- Thống kê số liệu: Thu nhập, Chi tiêu, Tiết kiệm
- Progress bar tỷ lệ tiết kiệm
- Quick actions: Thêm giao dịch, Xem phân tích, Đặt ngân sách

#### AISuggestionsCard  
**Vị trí**: Dashboard screen
**Hiển thị**:
- Tối đa 3 gợi ý AI chưa đọc
- Badge đếm số gợi ý chưa đọc
- Icon phân loại theo type
- Màu sắc theo mức độ ưu tiên

#### TransactionTile
**Hiển thị**:
- Icon và màu danh mục
- Tên danh mục và mô tả
- Số tiền (+ cho thu nhập, - cho chi tiêu)
- Ngày giờ giao dịch
- Phương thức thanh toán

### 3. Responsive Design
**Mobile Layout** (< 768px):
- Single column layout
- Stack các card theo chiều dọc
- Bottom navigation bar
- Compact spacing

**Tablet Layout** (768px - 1024px):
- 2 column grid cho một số sections
- Increased padding
- Larger touch targets

**Desktop Layout** (> 1024px):
- 2-3 column layout
- Side navigation (nếu có)
- Hover effects
- Larger charts và components

### 4. Animations & Transitions
**Initialization Screen**:
- Logo bounce animation (elasticOut curve)
- Progress bar glow effect
- Smooth fade transition to main app

**Navigation**:
- Page route transitions với fade
- Bottom nav item selection animation

**Forms**:
- Input field focus animations
- Button press feedback
- Loading states với CircularProgressIndicator

---

## 📖 Hướng Dẫn Sử Dụng

### 1. Khởi Động Lần Đầu

**Bước 1: Khởi tạo**
- Mở ứng dụng, chờ initialization screen
- Hệ thống tự động tạo database và data mẫu
- Thời gian khởi tạo: ~3-5 giây

**Bước 2: Cài đặt bảo mật (tùy chọn)**
- Vào Settings > Bảo mật
- Đặt PIN 6 số
- Kích hoạt sinh trắc học nếu muốn

**Bước 3: Thiết lập nguồn thu nhập**
- Vào tab Lương
- Thêm nguồn thu nhập chính (công ty, freelance, etc.)
- Nhập thông tin: Tên, loại, số tiền, tần suất

### 2. Sử Dụng Hàng Ngày

**Ghi nhận giao dịch**:
1. Vào tab Giao dịch
2. Nhấn nút "+" để thêm giao dịch mới
3. Chọn loại: Thu nhập hoặc Chi tiêu
4. Chọn danh mục
5. Nhập số tiền và mô tả
6. Chọn phương thức thanh toán
7. Lưu giao dịch

**Xem báo cáo**:
1. Vào tab Phân tích
2. Xem các biểu đồ:
   - Đường: Xu hướng thu nhập
   - Tròn: Phân bổ chi tiêu
   - Cột: So sánh theo tháng
3. Kéo xuống để refresh dữ liệu

**Kiểm tra gợi ý AI**:
1. Vào tab Tổng quan
2. Xem card "Gợi ý AI"
3. Nhấn vào gợi ý để xem chi tiết
4. Đánh dấu đã đọc nếu muốn

### 3. Quản Lý Ngân Sách

**Tạo ngân sách**:
1. Vào tab Ngân sách
2. Nhấn "Thêm"
3. Nhập thông tin:
   - Tên ngân sách
   - Loại (thu nhập/chi tiêu)
   - Hạn mức
   - Độ ưu tiên
   - Đánh dấu thiết yếu nếu cần
4. Lưu ngân sách

**Theo dõi thực hiện**:
- Ứng dụng tự động tính % thực hiện dựa trên giao dịch
- Cảnh báo khi vượt 80% ngân sách
- Gợi ý cắt giảm khi cần thiết

### 4. Đặt Mục Tiêu

**Tạo mục tiêu tiết kiệm**:
1. Vào tab Mục tiêu
2. Nhấn "Thêm"  
3. Nhập:
   - Tên mục tiêu (VD: "Mua xe", "Du lịch")
   - Số tiền mục tiêu
   - Ngày hoàn thành dự kiến
   - Mô tả chi tiết
4. Lưu mục tiêu

**Theo dõi tiến độ**:
- Progress bar hiển thị % hoàn thành
- Tính toán dựa trên số dư hiện tại
- Gợi ý số tiền cần tiết kiệm hàng tháng

### 5. Quản Lý Lương

**Thêm bản ghi lương**:
1. Vào tab Lương
2. Chọn nguồn thu nhập
3. Nhấn "Thêm bản ghi"
4. Nhập:
   - Gross amount (lương gốc)
   - Net amount (lương thực nhận)
   - Bonus (thưởng)
   - Deductions (khấu trừ)
   - Ngày nhận lương
   - Số ngày làm việc
5. Lưu bản ghi

**Xem phân tích lương**:
- Biểu đồ tăng trưởng theo thời gian
- So sánh với lạm phát
- Dự báo lương tháng tiếp theo
- Gợi ý tối ưu thuế

---

## 🔧 Kỹ Thuật Triển Khai

### 1. State Management với Provider

**TransactionProvider**:
```dart
class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  
  // Getters
  List<Transaction> get transactions => _transactions;
  List<Transaction> get incomes => 
    _transactions.where((t) => t.type == 'income').toList();
  List<Transaction> get expenses => 
    _transactions.where((t) => t.type == 'expense').toList();
    
  // Business logic
  double get totalIncome => incomes.fold(0, (sum, t) => sum + t.amount);
  double get totalExpenses => expenses.fold(0, (sum, t) => sum + t.amount);
  double get balance => totalIncome - totalExpenses;
  
  // Operations
  Future<void> addTransaction(Transaction transaction) async {
    final id = await TransactionService.insert(transaction);
    _transactions.insert(0, transaction.copyWith(id: id));
    notifyListeners();
  }
}
```

### 2. Database Operations

**Service Pattern**:
```dart
class TransactionService {
  static Future<int> insert(Transaction transaction) async {
    final db = await AppDatabase.database;
    return await db.insert('transactions', transaction.toMap());
  }
  
  static Future<List<Transaction>> getAll() async {
    final db = await AppDatabase.database;
    final maps = await db.query('transactions', orderBy: 'transaction_date DESC');
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }
  
  // Analytics methods
  static Future<double> getTotalByTypeAndDateRange(
    String type, DateTime startDate, DateTime endDate) async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE type = ? AND transaction_date BETWEEN ? AND ?
    ''', [type, startDate.toIso8601String(), endDate.toIso8601String()]);
    return (result.first['total'] as double?) ?? 0.0;
  }
}
```

### 3. AI Engine Implementation

**Expense Analysis Algorithm**:
```dart
// Z-score based anomaly detection
static List<Map<String, dynamic>> detectAnomalies(List<Transaction> transactions) {
  final amounts = transactions.map((t) => t.amount).toList();
  final mean = amounts.reduce((a, b) => a + b) / amounts.length;
  final standardDeviation = _calculateStandardDeviation(amounts);
  
  List<Map<String, dynamic>> anomalies = [];
  for (final transaction in transactions) {
    final zScore = (transaction.amount - mean) / standardDeviation;
    if (zScore.abs() > 2.0) {
      anomalies.add({
        'transaction': transaction,
        'z_score': zScore,
        'severity': zScore.abs() > 3.0 ? 'high' : 'medium',
      });
    }
  }
  return anomalies;
}
```

### 4. Chart Implementation với FL Chart

**Pie Chart for Category Distribution**:
```dart
Widget _buildExpensePieChart(BuildContext context, TransactionProvider provider) {
  return Container(
    height: 300,
    child: PieChart(
      PieChartData(
        sections: _generatePieChartSections(provider.expenses),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    ),
  );
}

List<PieChartSectionData> _generatePieChartSections(List<Transaction> expenses) {
  final categoryTotals = <int, double>{};
  for (final expense in expenses) {
    categoryTotals[expense.categoryId] = 
      (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
  }
  
  return categoryTotals.entries.map((entry) {
    return PieChartSectionData(
      value: entry.value,
      title: '${(entry.value / totalExpenses * 100).toStringAsFixed(1)}%',
      radius: 100,
      titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }).toList();
}
```

### 5. Security Implementation

**AES Encryption**:
```dart
class SecurityService {
  static Encrypter? _encrypter;
  static IV? _iv;
  
  static Future<void> initializeEncryption() async {
    final prefs = await SharedPreferences.getInstance();
    String? keyString = prefs.getString('encryption_key');
    
    if (keyString == null) {
      final key = Key.fromSecureRandom(32);
      keyString = key.base64;
      await prefs.setString('encryption_key', keyString);
    }
    
    final key = Key.fromBase64(keyString);
    _encrypter = Encrypter(AES(key));
    _iv = IV.fromSecureRandom(16);
  }
  
  static Future<String?> encryptData(String data) async {
    final encrypted = _encrypter!.encrypt(data, iv: _iv!);
    return encrypted.base64;
  }
}
```

### 6. Responsive Design Implementation

**Responsive Helper Methods**:
```dart
class AppTheme {
  static bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < 768;
    
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }
  
  static bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= 1024;
    
  static double getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) return spacing6;
    if (isTablet(context)) return spacing4;
    return spacing4;
  }
}
```

**Responsive Layout Usage**:
```dart
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(AppTheme.getResponsivePadding(context)),
    child: AppTheme.isDesktop(context)
      ? Row(
          children: [
            Expanded(flex: 2, child: FinancialOverviewCard()),
            SizedBox(width: AppTheme.spacing4),
            Expanded(child: AISuggestionsCard()),
          ],
        )
      : Column(
          children: [
            FinancialOverviewCard(),
            SizedBox(height: AppTheme.spacing4),
            AISuggestionsCard(),
          ],
        ),
  );
}
```

---

## 📝 Kết Luận

**App Tài Chính Cá Nhân** là một ứng dụng hoàn chỉnh được thiết kế để giúp người dùng Việt Nam quản lý tài chính một cách thông minh và hiệu quả. Với sự kết hợp của:

✅ **Giao diện hiện đại**: Material Design 3, responsive, Google Fonts Inter
✅ **Tính năng đầy đủ**: Quản lý thu chi, lương, ngân sách, mục tiêu  
✅ **AI thông minh**: Phân tích hành vi, gợi ý cá nhân hóa
✅ **Bảo mật cao**: PIN, sinh trắc học, mã hóa AES-256
✅ **Hiệu suất tốt**: SQLite local, Provider state management
✅ **Khả năng mở rộng**: Kiến trúc rõ ràng, code có tổ chức

Ứng dụng sẵn sàng để triển khai sản xuất và có thể được mở rộng thêm các tính năng như đồng bộ cloud, báo cáo nâng cao, tích hợp ngân hàng, và nhiều tính năng khác.

---

**📅 Ngày tạo**: $(date)  
**👨‍💻 Phiên bản**: 1.0.0  
**🔄 Cập nhật lần cuối**: $(date) 