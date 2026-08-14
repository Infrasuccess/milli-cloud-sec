# Qualys IaC Posture Setup Guide

## Overview

**IaC Posture** is a Qualys CSPM module that scans Infrastructure-as-Code artifacts for security and compliance issues. This enables you to identify configuration risks in your Terraform and CloudFormation templates **before** they're deployed to AWS.

## What is IaC Posture?

IaC Posture scanning detects:
- ✅ Security misconfiguration in code (unencrypted storage, exposed credentials, etc.)
- ✅ Compliance violations (CIS, PCI-DSS, SOC 2, etc.)
- ✅ Overly permissive IAM policies
- ✅ Missing security controls
- ✅ Infrastructure best practice violations

**Supported formats:**
- Terraform (.tf files)
- CloudFormation (.yaml, .json templates)
- AWS SAM (Serverless Application Model)

---

## Your Current Setup

### Enabled Services

✅ **CSPM (Cloud Security Posture Management)**
- Scans live AWS resources
- Detects runtime configuration issues
- Monitors compliance drift

✅ **IaC Posture** (now enabled)
- Scans your Terraform code
- Detects issues before deployment
- Integrated with your pipeline

---

## IAM Permissions for IaC Posture

The Qualys role now includes permissions for:

### CloudFormation Access
```hcl
"cloudformation:Describe*"
"cloudformation:GetTemplate*"
"cloudformation:List*"
```
Required to scan CloudFormation templates and stacks.

### S3 Terraform State
```hcl
"s3:GetObject"
"s3:ListBucket"
# Targets: *-terraform-state* buckets
```
Required to read Terraform state files and backend configurations.

### Logs
```hcl
"logs:DescribeLogGroups"
"logs:DescribeLogStreams"
"logs:GetLogEvents"
```
Required for audit trail and scanning logs.

---

## How to Enable IaC Posture in Qualys Portal

### Step 1: Verify IAM Role Deployed
After terraform-apply completes, the Qualys role is created with IaC permissions.

**Check deployment:**
1. Go to GitHub Actions → **terraform-apply.yml** last run
2. Look for output: `qualys_role_arn`
3. Example: `arn:aws:iam::123456789012:role/milli-cloud-sec-devsec-qualys-cspm-role`

### Step 2: Navigate to Qualys Portal

1. Log in to **Qualys CSPM** → https://cloudview.qualys.com
2. Go to **Integrations** → **Cloud Connectors**
3. Select your **AWS Connector** (already created from CSPM setup)
4. Click **Edit** or **Configure**

### Step 3: Enable IaC Posture Module

1. In the connector settings, find **IaC Posture** or **Code Scanning** section
2. Select **Enable IaC Posture**
3. Choose modules to enable:
   - ✅ **Terraform**
   - ✅ **CloudFormation**
   - ✅ **Other IaC Formats** (if applicable)

### Step 4: Configure Scanning Scope

**Terraform Repository Access:**
- Option A: Qualys scans your S3 backend state
- Option B: Connect GitHub repo for source scanning (requires GitHub token)

**Your Setup:** Uses S3 backend
- Qualys will scan: `*-terraform-state*` S3 buckets
- Automatically discovers `.tf` and `.tfstate` files

### Step 5: Save and Start Scan

1. Click **Save** to enable IaC Posture
2. Click **Run Assessment** or **Start Scan**
3. Qualys will scan your Terraform code immediately

---

## What Gets Scanned

### Your Repository Structure
```
milli-cloud-sec/
├── terraform/
│   ├── variables.tf          ← Scanned
│   ├── ec2.tf               ← Scanned
│   ├── security_groups.tf   ← Scanned
│   ├── network.tf           ← Scanned
│   ├── iam.tf               ← Scanned
│   ├── qualys_cspm.tf       ← Scanned
│   ├── elastic_ips.tf       ← Scanned
│   ├── budget.tf            ← Scanned
│   ├── scheduler.tf         ← Scanned
│   └── terraform.tfvars     ← NOT Scanned (sensitive)
└── .github/
    └── workflows/           ← Scanned
```

### Sample Findings

Example issues Qualys IaC Posture might identify:
- ❌ Security group allows 0.0.0.0/0 for SSH (port 22)
- ❌ S3 bucket lacks encryption
- ❌ IAM policy uses wildcard actions (*)
- ❌ EC2 instance lacks security group
- ❌ EBS volume not encrypted
- ⚠️ Elastic IP allocation without instance (cost waste)

---

## Viewing Scan Results

### In Qualys Portal

1. **Dashboard** → IaC Posture
2. See:
   - **Total Issues Found**
   - **Risk Level** (Critical, High, Medium, Low)
   - **Affected Files** (terraform/*.tf)
   - **Remediation Guidance**

### Export Results

1. Click **Export** (CSV, JSON, PDF)
2. Import into your pipeline for automated tracking
3. Integrate with GitHub Issues for tracking

---

## Your Terraform Code - IaC Posture Review

### Current Configuration Status

✅ **Security Groups**
- SSH restricted to your IP (108.239.113.218/32)
- HTTP/HTTPS open (intentional for testing)

✅ **EC2 Instances**
- Using t2.micro (free tier eligible)
- SSM Agent installed (allows Session Manager)

✅ **IAM**
- Qualys role: read-only permissions only
- Budget alert role: minimal permissions
- Instance profiles: properly scoped

✅ **Network**
- VPC with proper subnet isolation
- Network ACLs configured
- Route tables properly configured

⚠️ **Potential Findings** (expected in dev environment)
- Elastic IPs reserved but might be unused (cost)
- S3 bucket for Terraform state (should verify encryption)
- DynamoDB for state locking (should verify encryption)

---

## CI/CD Integration - GitHub Actions

### Scan Results in Your Pipeline

After enabling IaC Posture in Qualys:

1. **Weekly Automated Scans**
   - Qualys scans your S3 Terraform state
   - Results appear in Qualys dashboard
   - Can integrate with GitHub Issues

2. **On-Demand Scans**
   - Trigger manually via Qualys portal
   - Results posted to GitHub PR comments
   - Blocks deployment if critical issues found

### Potential Integration

**Future Enhancement** (not yet implemented):
```yaml
# .github/workflows/iac-posture-check.yml
- name: Fetch Qualys IaC Scan Results
  run: |
    curl https://qualys-api.com/iac-scans \
      -H "Authorization: Bearer ${{ secrets.QUALYS_API_TOKEN }}" \
      -o iac-results.json
    
    # Check for critical findings
    python scripts/check_iac_findings.py iac-results.json
```

---

## Cost Implications

### IaC Posture Licensing

- **Included with Qualys CSPM** subscription
- **No additional cost** for basic IaC scanning
- Premium features (GitHub integration, real-time) may require upgrade

### Your Setup Impact
- ✅ API calls to S3 (read Terraform state): ~$0.0004 per API call
- ✅ CloudFormation API calls: minimal
- ✅ Logs API calls: minimal
- **Total impact:** <$0.01/month

---

## Monitoring and Maintenance

### Dashboard Checks

**Weekly:**
- Review new findings in Qualys dashboard
- Categorize findings (will-fix, accepted-risk, false-positive)
- Update Terraform code to remediate critical issues

**Monthly:**
- Trend analysis (are findings increasing/decreasing?)
- Compare against previous month
- Update remediation timelines

### Updating Your Code

When Qualys finds issues:

1. **Fix in Terraform** (e.g., add encryption, restrict access)
2. **Commit to GitHub** (enables version control)
3. **Run terraform-apply** (deploys fixed infrastructure)
4. **Re-scan in Qualys** (confirms remediation)

Example flow:
```bash
# Git flow (through GitHub UI)
1. Edit terraform/security_groups.tf
2. Create Pull Request
3. ci-security.yml validates changes
4. After merge, terraform-apply deploys
5. Qualys re-scans within 24 hours
6. View remediation in Qualys dashboard
```

---

## Troubleshooting

### IaC Posture Not Scanning

**Issue:** Qualys shows no IaC findings

**Solutions:**
1. Verify module is enabled in Qualys portal
2. Check S3 bucket permissions:
   ```
   Qualys role must have: s3:GetObject on *-terraform-state* buckets
   ```
3. Verify Terraform backend bucket name matches pattern
4. Check Qualys connector logs in portal

### Too Many False Positives

**Solutions:**
1. Review each finding in Qualys portal
2. Mark false positives as "Accepted Risk"
3. Filter findings by severity (hide Low/Info)
4. Adjust policy rules in Qualys portal

### Scanner Access Issues

**Issue:** Qualys role can't access S3 state

**Solutions:**
1. Verify S3 bucket has no encryption KMS restrictions
2. Check S3 bucket policy doesn't deny Qualys role
3. Ensure `qualys_account_id` is correct (805950163170)
4. Verify `external_id` matches Qualys configuration (US3-9214256)

---

## Next Steps

1. ✅ Terraform deployed (IaC Posture IAM permissions added)
2. ⬜ Log into Qualys portal
3. ⬜ Enable IaC Posture in AWS connector settings
4. ⬜ Start first IaC scan
5. ⬜ Review findings and remediate
6. ⬜ Set up weekly scan cadence

---

## Configuration Summary

**Your Current Settings:**
```hcl
enable_qualys_cspm        = true
enable_qualys_iac_posture = true
qualys_account_id         = "805950163170"
qualys_external_id        = "US3-9214256"
```

**IAM Permissions Added:**
- CloudFormation scanning
- S3 Terraform state access
- Logs for audit trail

**Scans Your:**
- All `.tf` files in repository
- CloudFormation templates
- Terraform state files
- Historical configurations

---

## Support & Documentation

- **Qualys CSPM Docs:** https://qualysguard.qualys.com/qwebhelp/en_US/cspm/
- **IaC Posture Guide:** https://qualysguard.qualys.com/qwebhelp/en_US/cspm/Content/Topics/CSPM/IaC_Posture.htm
- **AWS Connector Setup:** Check Qualys portal → Integrations → Documentation

---

**Last Updated:** 2026-08-14
**Status:** ✅ IaC Posture enabled and ready for scanning
