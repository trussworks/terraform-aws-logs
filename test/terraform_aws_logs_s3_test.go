package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestTerraformAwsLogsS3(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/s3")
	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"region":         awsRegion,
			"test_name":      testName,
			"force_destroy":  true,
			"s3_logs_prefix": testName,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}

func TestTerraformAwsLogsS3RootPrefix(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/s3")
	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"region":         awsRegion,
			"test_name":      testName,
			"force_destroy":  true,
			"s3_logs_prefix": "",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
