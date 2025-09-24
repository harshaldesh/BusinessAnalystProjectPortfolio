# 📊 Credit Risk Analysis Dashboard  

## 📌 Project Overview  
This project focuses on analyzing **Credit Risk** using a real-world credit dataset. The Power BI dashboards provide insights into:  
- Loan performance  
- Default rate trends  
- Risk segmentation by income, age, home ownership, and loan grade  
- Identification of high-risk customer groups  

The analysis helps financial institutions assess **default risk drivers** and make better lending decisions.  

---

## 🗂️ Files in Repository  
- `Credit_Risk_Analysis.pbix` → Power BI report file  
- `README.md` → Project documentation  
- `Data/` → Dataset used for analysis (if public)  
- `Screenshots/` → Images of the dashboards  

---

## 🛠️ Tools & Technologies  
- **Power BI** → Data visualization & dashboard building  
- **DAX** → Measures and calculations  
- **SQL / Excel (optional)** → Data preprocessing  
- **Dataset** → Public Credit Risk dataset  

---

## 📈 Dashboard Pages  

### 🔹 Page 1: Executive Summary  
- **KPIs**: Total Loan Amount, Total Defaults, Default Rate %, Average Income  
- **Charts**:  
  - Risk by Loan Purpose (Bar Chart)  
  - Total Loan by Interest % (Column Chart)  
  - Distribution of Loans by Home Ownership (Donut Chart)  
  - Default Rate % by Age Band (Bar Chart)  
  - Credit Grade Performance (Matrix)  

---

### 🔹 Page 2: Risk Segmentation & Drivers  
- **KPIs**: High-Risk Applications, Avg Loan Amount (Defaults), Avg Income of Defaulters  
- **Charts**:  
  - Average Income by Home Ownership (Bar Chart)  
  - Default Rate % by Home Ownership (Line Chart)  
  - Default Rate % by Income Band (Bar Chart)  
  - Default Rate % by Loan Grade (Pie Chart)  
  - High-Risk Applications by Loan Purpose (Combo Chart)  
  - Income Band × Loan Grade × Default Rate % (Matrix with conditional formatting)  

---

## 📊 Key Insights  
- Higher **loan grades (E–G)** show significantly higher default rates.  
- **Low-income groups** have the highest probability of default.  
- **Renters** and those with **medical / debt consolidation loans** are at greater risk.  
- Younger borrowers (under 25) also show relatively higher default rates.  

---

## 🚀 How to Use  
1. Clone this repository  
   ```bash
   git clone https://github.com/yourusername/credit-risk-analysis.git
