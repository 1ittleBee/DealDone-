# Master Plan (A to Z): DealDone (সহজ বাংলা চুক্তি ও লেনদেনের লিখিত প্রমাণ)

**Project Codename:** `DealDone` (ডিজিটাল চুক্তি ও রসিদ সহকারী)  
**Target Platforms:** Android & iOS (Built with Flutter)  
**App Type:** 100% Offline-First Legal Agreement & Receipt Generator  
**Market:** Bangladesh (General Public, Buyers/Sellers of Used Goods, Tenants, Freelancers, Small Contractors)  

---

## 1. Executive Summary & Market Problem

### 1.1 The Cultural Problem: "The Awkwardness Trap" (লজ্জা ও ক্ষতি)
In Bangladesh, hundreds of thousands of financial and commercial transactions occur daily on verbal trust alone:
- **Used Product Sales:** Selling a used motorcycle, smartphone, or laptop on Bikroy.com or Facebook Marketplace with no paperwork proving the item is not stolen.
- **Personal Loans (করজে হাসানা / ধার):** Lending ৳20,000–৳50,000 to a friend, colleague, or relative.
- **Flat Booking Advance (বায়না):** Paying a ৳5,000–৳10,000 deposit to lock in a rental apartment.
- **Service Work Advances:** Handing ৳15,000 advance to a carpenter, painter, or wedding decorator.

### 1.2 Why Physical Stamp Papers Fail for Daily Deals
1. **Cost & Delay:** Purchasing ৳300 non-judicial stamps, finding a typist, and notary endorsement costs ৳1,000–৳2,500 and takes half a day.
2. **Social Discomfort:** Asking a cousin or friend to sign a formal court stamp is perceived as an insult (*"আপনি কি আমাকে বিশ্বাস করেন না?"*).

### 1.3 The Solution
A **60-second mobile application** that reframes formal legal drafting into a polite, respectful **mutual digital handshake**:
> *"ভাই, কিছু মনে করবেন না, এই অ্যাপে দুজনের নাম আর তারিখটা দিয়ে একটা রসিদ সেভ করে রাখি—যেন দুজনেরই মনে থাকে।"*

Both parties enter details, sign on the phone screen with their finger, snap a quick NID photo, and receive a beautifully formatted, timestamped PDF agreement directly on WhatsApp.

---

## 2. Legal Admissibility Framework (Bangladesh Law)

The app is built strictly upon existing Bangladeshi legislation:

```
                            ┌─────────────────────────────────────────┐
                            │    Bangladeshi Legal Framework          │
                            └────────────────────┬────────────────────┘
                                                 │
          ┌──────────────────────────────────────┼──────────────────────────────────────┐
          ▼                                      ▼                                      ▼
┌───────────────────────────────┐ ┌───────────────────────────────┐ ┌───────────────────────────────┐
│     The Contract Act, 1872    │ │ The Evidence (Amendment) 2022 │ │     The Stamp Act, 1899       │
│                               │ │                               │ │                               │
│ • Sec 10: Contracts are valid │ │ • Sec 85A: Court legally      │ │ • Plain paper/digital docs    │
│   by mutual free consent,     │ │   presumes validity of        │ │   are valid secondary proof.  │
│   lawful consideration &      │ │   digitally signed agreements.│ │ • Stamp deficit can be paid   │
│   lawful object.              │ │ • Sec 65B: Electronic records │ │   under Sec 35 if ever        │
│ • No stamp paper required for │ │   fully admissible in court.  │ │   admitted in civil suit.     │
│   daily civil validity.       │ │ • Sec 3: "Document" includes  │ │ • Prevents verbal disputes    │
│                               │ │   digital mobile files.       │ │   completely.                 │
└───────────────────────────────┘ └───────────────────────────────┘ └───────────────────────────────┘
```

### 2.1 Essential Boundary & Mandatory Disclaimers
1. **Exclusion of Immovable Property Transfer:** Under Section 17 of The Registration Act 1908, land and building ownership transfer must be registered at the Sub-Registry office. The app expressly states:
   > *"এই রসিদটি কেবল পারস্পরিক প্রমাণ ও লেনদেনের স্মারক। এটি জমি বা ফ্ল্যাটের সাব-রেজিস্ট্রি দলিলের বিকল্প নয়।"*
2. **Self-Service Software Platform:** The app acts as a document generator (like Canva or DocuSign) and does not provide legal representation or advocate services.

---

## 3. Core Agreement Templates (The MVP Suite)

```
                            ┌────────────────────────────────────────────────────────┐
                            │               BaynaChukti Template Suite               │
                            └───────────────────────────┬────────────────────────────┘
                                                        │
         ┌──────────────────┬───────────────────┼───────────────────┬──────────────────┬──────────────────┐
         ▼                  ▼                   ▼                   ▼                  ▼                  ▼
  ┌──────────────┐   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
  │  Template 1  │   │  Template 2  │    │  Template 3  │    │  Template 4  │   │  Template 5  │   │  Template 6  │
  │ Used Gadget/ │   │Personal Loan │    │Flat Advance/ │    │ Service Work │   │General Mutual│   │Salish & Gram │
  │ Vehicle Sale │   │& Promissory  │    │ Bayna Slip   │    │& Gig Advance │   │  Agreement   │   │ Adalat Slip  │
  └──────────────┘   └──────────────┘    └──────────────┘    └──────────────┘   └──────────────┘   └──────────────┘
```

### Template 1: Used Product / Vehicle Sale (পুরাতন জিনিস ও গাড়ি বিক্রয় চুক্তি)
* **Use Case:** Selling used bikes, cars, laptops, or iPhones on Bikroy.com or Facebook.
* **Key Clauses:**
  - Seller certifies full ownership and that the item is free of police complaints, theft reports, or loan hypothecation.
  - Buyer acknowledges receiving the item in running/as-is condition.
  - Device/Engine details: IMEI number, Engine/Chassis number, BRTA registration number.

### Template 2: Personal Loan & Promissory Note (করজে হাসানা / টাকা ধার ও পরিশোধের অঙ্গীকারনামা)
* **Use Case:** Lending money to colleagues, relatives, or business acquaintances.
* **Key Clauses:**
  - Lender details, Borrower details, exact loan amount in numbers and Bangla words.
  - Repayment commitment date (*পরিশোধের শেষ তারিখ*).
  - Mode of delivery (Cash, bKash transaction ID, or Bank transfer receipt).
  - Non-interest statement (*করজে হাসানা / সুদমুক্ত ঋণ*).

### Template 3: Rental Flat Booking & Bayna Slip (বাসাভাড়া বুকিং ও অগ্রিম বায়না রশিদ)
* **Use Case:** Securing an apartment before moving in next month.
* **Key Clauses:**
  - Flat address, Landlord name, Prospective tenant name.
  - Advance payment amount received.
  - Agreed monthly rent and security deposit balance.
  - Agreed move-in date and cancellation/refund policy.

### Template 4: Contractor / Freelance Service Advance (কাজের অগ্রিম ও চুক্তিপত্র)
* **Use Case:** Home interior, painting, carpentry, wedding photography, or custom tailoring.
* **Key Clauses:**
  - Description of work deliverable.
  - Total agreed price and advance paid today.
  - Completion deadline and revision terms.

### Template 5: General Mutual Agreement (সাধারণ পারস্পরিক অঙ্গীকারনামা)
* **Use Case:** Open-ended mutual agreement with custom conditions for roommates, partners, or local arrangements.

### Template 6: Village Arbitration & Dispute Settlement Slip (গ্রাম্য সালিশ ও আপোষনামা রেকর্ডার)
*The game-changing grassroots dispute resolution feature.*
* **The Rural Problem:** Outside major metros, thousands of boundary quarrels, matrimonial friction, tree-cutting/crop disputes, and small financial claims are resolved via local community arbitration (*গ্রাম্য সালিশ / শালিস*). Because verdicts are verbal, one party reneges 6 months later, sparking physical violence and costly court battles.
* **Key Capabilities:**
  - **Dispute Classification:** Boundary/Land demarcation (*সীমানা নির্ধারণ*), Crop/Property damage (*ফসল ও গাছ কাটার ক্ষতিপূরণ*), Family/Matrimonial compromise (*পারিবারিক আপোষ*), Petty financial restitution (*ক্ষতিপূরণ পরিশোধ*).
  - **Multi-Party Sign-off:** First Party (*বাদী পক্ষ*), Second Party (*বিবাদী পক্ষ*), and **up to 3 Neutral Village Elders / Union Parishad Members (*শালিসদার / মুরুব্বি*)**.
  - **Voice Ruling Note (শ্রুতলিপি ও অডিও রেকর্ড):** Record a 60-to-120-second audio summary of the elders' verbal decision right on the phone. Illiterate parties can listen back anytime.
  - **Fingerprint / Thumbprint Capture:** Camera snapshot of the physical ink thumbprint (*টিপসই*) or digital on-screen thumbprint alongside drawn signatures.
  - **Laminated Formal Certificate Output:** Generates an official-looking, government-court aesthetic certificate (*"শালিসনামা ও সর্বসম্মত আপোষপত্র"*), ready to print, laminate, and preserve permanently.

---

## 4. User Experience & Document Creation Flow

```
[1. Select Template] ──► [2. Quick Details Form] ──► [3. Digital Finger Sign]
                                                             │
[6. WhatsApp Share] ◄── [5. High-Res PDF Created] ◄── [4. Witness / Photo]
```

### 4.1 Step-by-Step Flow:
1. **Template Selection:** 1-tap choice with clear icons and Bengali labels.
2. **Smart Form Fields:**
   - Party 1 (First Party / প্রথম পক্ষ): Name, Mobile Number, NID (Optional).
   - Party 2 (Second Party / দ্বিতীয় পক্ষ): Name, Mobile Number, NID (Optional).
   - Transaction Terms: Amount (৳), Delivery/Due Date, Description.
3. **On-Screen Signature Pad:**
   - Smooth vector finger signature canvas for both parties.
4. **Photo Attachment (Optional):**
   - Take a quick snapshot of the item being sold, NID card, or bank transfer slip.
5. **Witness Details (Optional):**
   - Names and phone numbers of 1 or 2 neutral witnesses.
6. **PDF Engine:**
   - Generates a clean, single-page, government-aesthetic PDF document with:
     - Header: *"দ্বিপাক্ষিক লেনদেনের স্মারক ও অঙ্গীকারনামা"*
     - Unique Document ID: `BC-2026-XXXXX`
     - Exact timestamp and location coordinates
     - QR verification code
     - Signatures and photo attachments
7. **1-Tap Share:** Direct export to WhatsApp, Messenger, or save to device storage.

---

## 5. Technology Stack & Technical Architecture

### 5.1 Architecture Stack
| Layer | Technology | Rationale |
| :--- | :--- | :--- |
| **Framework** | **Flutter 3.x (Dart)** | Unified cross-platform for Android & iOS with high-performance UI. |
| **PDF Generation** | **`pdf` + `printing`** | Generates pixel-perfect vector PDF documents locally on device without network latency. |
| **Signature Engine** | **`signature`** | Captures smooth, anti-aliased finger strokes and exports as transparent PNG. |
| **Local Storage** | **`hive` or `isar`** | Fast, encrypted NoSQL offline database to store past agreement history. |
| **Image & Thumbprint** | **`image_picker` + `image_cropper`** | Captures receipts, NID pictures, and physical ink thumbprints (`টিপসই`). |
| **Audio Voice Note** | **`record` + `audioplayers`** | Records and replays 60-to-120-sec verbal rulings for Village Salish agreements. |
| **Sharing** | **`share_plus`** | Native integration with WhatsApp, Telegram, Gmail, and Bluetooth. |

### 5.2 Folder & Code Layout
```
bayna_chuktigari/
├── docs/
│   ├── MASTER_PLAN_A_TO_Z.md          <-- Master blueprint
│   ├── LEGAL_COMPLIANCE_GUIDE.md      <-- Bangladeshi laws, Evidence Act 2022
│   └── CONTRACT_TEMPLATES_SPEC.json   <-- Bengali clauses & template schemas
├── lib/
│   ├── core/
│   │   ├── constants/                 <-- Bengali strings, app colors, typography
│   │   ├── theme/                     <-- Clean white & navy formal theme
│   │   └── utils/                     <-- Number to Bangla words converter (টাকা কথায়)
│   ├── features/
│   │   ├── templates/                 <-- Agreement template repository
│   │   ├── creator_wizard/            <-- Multi-step agreement input screens
│   │   ├── signature/                 <-- Finger signature canvas modal
│   │   ├── pdf_generator/             <-- Bengali PDF layout and styling engine
│   │   └── history/                   <-- Local archive of created agreements
│   └── main.dart                      <-- Entry point
└── test/
    └── pdf_generation_test.dart       <-- PDF layout and rendering test cases
```

---

## 6. Privacy & Zero-Cloud Security Architecture

* **Zero Central Cloud Server:**
  - Many users hesitate to input NID numbers or monetary amounts into online databases.
  - **By design, 100% of data remains exclusively on the user’s physical phone.**
  - There is no central server to hack, leak, or subpoena.
* **Tamper-Evident SHA-256 Hash:**
  - When the PDF is finalized, the app computes a SHA-256 hash of the document content and embeds it as a QR code on the footer.
  - If someone later alters a number in the PDF, the hash will not match the original generation record.

---

## 7. Product-Led Growth & Distribution Strategy

### 7.1 Built-in Viral Distribution ("The Dual-Receipt Effect")
1. Every agreement involves **at least two people** (Buyer & Seller, Lender & Borrower, Landlord & Tenant).
2. Person A creates the agreement and sends it to Person B on WhatsApp.
3. Person B opens the professional document, verifies the signature, and notices:
   ```
   --------------------------------------------------------------
   ✓ এই ডিজিটাল চুক্তিপত্রটি তৈরি হয়েছে 'বায়না ও চুক্তি' অ্যাপ দিয়ে।
   প্লে-স্টোর থেকে ডাউনলোড করুন: [ShortLink]
   --------------------------------------------------------------
   ```
4. **Every single transaction organically introduces a new user.**

### 7.2 Community & Marketplace Marketing
* **Bikroy.com & Facebook Marketplace:**
  - Share tutorial videos: *"পুরাতন বাইক বা ফোন কেনার পর নিশ্চিত থাকবেন কীভাবে? ৬০ সেকেন্ডে বানিয়ে নিন বিক্রয় চুক্তিপত্র।"*
* **Bachelor & Flat-to-Let Groups:**
  - Post guides on protecting advance booking money (*বায়না*) from fraudulent brokers.

---

## 8. Step-by-Step Implementation Roadmap

| Phase | Milestone | Deliverable |
| :---: | :--- | :--- |
| **Phase 1** | **Legal Text & Template Engine** | Finalize Bengali legal clauses for 5 core templates; build Bangla number-to-words converter. |
| **Phase 2** | **Signature Pad & Input Wizard** | Reactive form wizard, smooth signature canvas, and NID photo capture. |
| **Phase 3** | **Offline PDF Engine** | Embed Bengali fonts (*Hind Siliguri*), construct formal document layout with QR code and verification hash. |
| **Phase 4** | **Local Vault & Share Sheet** | Encrypted local storage archive of past slips, 1-tap WhatsApp PDF exporter. |
| **Phase 5** | **Polish, Disclaimers & Store Launch** | Legal disclaimers onboarding, dark/light themes, Google Play Store listing. |

---
*Maintained in `f:\App Projects Ideas\bayna_chuktigari\`.*
