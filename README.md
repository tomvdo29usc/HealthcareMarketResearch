# Summary
Heart diseases and cancer are major causes of death for adults in the United States. This study explores healthcare utilization patterns for patients with cancer versus heart diseases using the SynUSA data developed by Prof. Steve Parente.

**Key Analyses**

1. **Average Total Allowed Amount and Visits**: We examined these metrics at different places of service for condition groups (cancer only, heart diseases only, both, and neither).

2. **Utilization Patterns by Age**: We analyzed how utilization varied among age groups for cancer-only and heart-diseases-only patients.

3. **Insurance Types**: We explored average utilization across different insurance types for each condition.
4. **Regional Variations**: We looked at how the average allowed amount varied across US states and regions.
   
**Findings**

- Higher Utilization for Diagnosed Patients: Patients with cancer or heart diseases had higher average care utilization in terms of visits and allowed amount, with patients having both conditions consuming care as much as those with either condition combined.
- Age-related Patterns: Older populations had higher incidences of these diseases, but pediatric cancer patients had higher average allowed amounts due to better treatment outcomes. No significant age-related differences were observed for heart-diseases-only patients.
- Insurance Type Impact: Non-group and Medicaid enrollees showed higher average allowed amounts, likely due to socioeconomic factors and minimal care delivery increasing their care-seeking behavior.
- Regional Differences: Western states had higher care utilization, potentially due to less developed care systems and hospitals having more pricing power in rural areas.
We used multiple ANOVA tests to ensure statistical significance of our findings.

# 1. STUDY DATA AND METHODS
This research used the Synthetic USA (SynUSA) dataset developed by Professor Steve Parente at the University of Minnesota. The SynUSA dataset includes 184,851 beneficiary records and over six million claim records from 2015, covering five major insurance types: Employer Sponsored Insurance, Medicaid, Medicare Fee-For-Service, Medicare Advantage, and Non-Group. Below is the overview of the data and method:

## 1.1 Beneficiary Details
- **Beneficiary Details**: Insurance type, state, region, age, sex, federal poverty level, and household income.
- **Claim Details**: Claim type, ICD-9 diagnosis codes, allowed amount, specialty codes, place of service codes, and claim dates.

## 1.2 Disease Categorization
Beneficiaries were classified into four categories based on their claims
1. Cancer Only
2. Heart Diseases Only
3. Both Conditions
4. Neither Condition

## 1.3 Place of Service Grouping
1. Professional Claims: Primary care, cardiologist, oncologist, and other visits.
2. Facility Claims: Inpatient and outpatient facilities.
   
## 1.4 Analysis
We analyzed patterns of care utilization, focusing on the average allowed amount and number of visits across different places of service, age groups, insurance types, and states. ANOVA tests confirmed the statistical significance of mean differences among groups.

# 2. ANALYSIS RESULTS AND DISCUSSIONS
## 2.1 Healthcare Utilization Patterns in terms of Allowed Amount and Visits
The SynUSA dataset included 184,851 beneficiaries, with 52.93% female and various age groups: 20.94% were 65 or older, 29.58% were 45-64, 11.60% were 35-44, 17.28% were 19-34, and 20.59% were teenagers. The prevalence of heart diseases was 9.79%, cancer was 4.75%, and 1.5% had both conditions, aligning with CDC statistics.
<img width="1181" alt="image" src="https://github.com/user-attachments/assets/9415adeb-4cdb-4723-8ecc-ca31c5b234a5">

> **💡FINDINGS**
> - Cost and Visits: Diagnoses of cancer and heart diseases significantly increased healthcare costs and visits across all service places. Patients with these conditions incurred about six times higher costs than those without.
> - Average Costs: Patients with both conditions had costs similar to the sum of patients with either condition alone. Heart disease treatment costs were slightly higher than cancer treatment.
> - Visits: Primary and other professional visits were common, while outpatient visits dominated at the facility level. Heart disease patients generally had more visits than cancer patients, especially inpatient visits, suggesting more complications and intensive care needs. Patients with both conditions had the highest visit rates across all services, indicating a need for constant monitoring.

The differences in costs and visits by condition were statistically significant (p < 0.0001).

## 2.2 Healthcare Utilization Patterns by Age Groups
Older age groups had higher diagnoses of cancer, heart diseases, or both. Over 90% of patients with these conditions were 45 or older.

<img width="1084" alt="image" src="https://github.com/user-attachments/assets/8824e822-c8f1-48a3-b1bb-5ede017c4b54">

> **💡FINDINGS**
> - Higher Costs for Older Groups: Average allowed amounts for patients with cancer or heart diseases were higher than those without these conditions across all age groups.
> - Pediatric Cancer Costs: Despite being less common, pediatric cancer had very high costs due to complex, resource-intensive treatments. Younger children incurred even higher costs.
> - Heart Disease Costs: Average costs for heart-diseases-only patients showed little variation across age groups, an area for further research.
  
The differences in mean allowed amounts by age and condition were statistically significant (p < 0.0006 for heart diseases only, p < 0.0001 for other conditions).

## 2.3 Healthcare Utilization by Insurance Types
Non-group and Medicaid beneficiaries used more healthcare services than other groups. Medicaid members with cancer had the highest average allowed amounts, followed by Non-group and ESI members. Similarly, for heart diseases, Medicaid and Non-group beneficiaries had the highest costs. For patients with both conditions, Non-group and Medicaid also led in average costs.
<img width="1092" alt="image" src="https://github.com/user-attachments/assets/6cfd179d-eecc-43a1-b624-f85ad232371c">

> **💡Interpretation**
> - Income and Coverage: Most Non-group enrollees and Medicaid members have incomes below 400% of the federal poverty level and often have only minimal essential coverage. They are more likely to be low-income individuals, families, pregnant women, the elderly, and people with disabilities.
> - Health Risks: These groups are at higher risk of diseases due to poor lifestyle and living conditions, increasing their healthcare utilization.
> - Care Quality and Access: Medicaid is often associated with lower care quality and poor outcomes, leading to more frequent care seeking. Patients also face challenges accessing routine and specialized care, worsening their conditions.
> - Medicare Advantage: Medicare had the lowest utilization across all conditions. People on Medicare Advantage plans use fewer services and spend less, although these plans have high premiums and are not accessible to everyone.

The differences in average allowed amounts by insurance type were statistically significant (p < 0.0001 for all conditions).

## 2.3 Healthcare Utilization by States
Beneficiaries in the Western states generally had higher average allowed amounts than those in other regions. Utah, Montana, Idaho, and Oregon had some of the highest averages for beneficiaries with cancer (see Exhibit 4). For heart diseases only, Montana, Idaho, Oregon, Illinois, and Indiana had high averages (see Exhibit 4). Patients with both conditions had the highest average allowed amounts in Utah and Idaho (see Exhibit 4). ANOVA tests confirmed that state differences in average allowed amounts were significant, indicating higher care utilization in these Western states. Research shows hospitals in Montana charge private insurers two to three times more than Medicare and that rural patients pay slightly more due to hospitals' pricing power (Houghton, 2019).
<img width="1012" alt="image" src="https://github.com/user-attachments/assets/3f4036d7-d283-4a82-9fbd-be33722032dc">

Our analysis had some limitations. In fact, the SynUSA data did not include pharmacy claim data; therefore, we could not see patterns of drug spending. Medication was a big part of treatment for these conditions, especially among patients with heart diseases. Missing prescription data might underestimate the average allowed amount of beneficiaries, especially, with heart diseases only and both conditions. Also, the SynUSA data did not have beneficiaries from high-populated and diverse states such as California, Texas, New York, and Florida. We might not see how beneficiaries of thoses states contributed to the patterns that we saw.

## CONCLUSION
We analyzed healthcare utilization patterns among patients with cancer and heart diseases using the SynUSA dataset from Professor Steve Parente. Beneficiaries were categorized into those with cancer only, heart diseases only, both conditions, or neither. Utilization was measured by average allowed amounts and visit frequencies for primary care, cardiologists, oncologists, and other providers, as well as for inpatient and outpatient facility claims. We examined variations by condition group, age, insurance type, and state, and used ANOVA tests to ensure statistical significance.

Patients with cancer and/or heart diseases had significantly higher utilization of services and costs compared to those with neither condition. Pediatric cancer, though rare, is notably expensive. Given the higher prevalence of these conditions among older adults, promoting a healthy lifestyle could reduce risk. Non-group and Medicare insurance types often provide lower care quality and less timely access, leading to increased utilization. We recommend allowing beneficiaries to choose benefits tailored to their needs rather than relying on minimum coverage, which could improve access and care quality. Utilization was notably higher in some Western states; for instance, Montana’s healthcare system and premiums are deemed unaffordable, highlighting the need for systemic change (Houghton, 2019).





