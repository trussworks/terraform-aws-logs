package test

import (
	"fmt"
	"strings"
	"testing"

	awssdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestTerraformAwsLogs(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/simple")
	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"region":        awsRegion,
			"test_name":     testName,
			"force_destroy": true,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}

func TestTerraformAwsLogsWithConflictingTags(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/simple")
	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"region":        awsRegion,
			"test_name":     testName,
			"force_destroy": true,
			"tags": map[string]string{
				"Name": "darkwing duck",
				"Test": "true",
			},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	s3Client, err := aws.NewS3ClientE(t, awsRegion)
	require.NoError(t, err)

	params := &s3.GetBucketTaggingInput{
		Bucket: awssdk.String(testName),
	}

	taggingOutput, err := s3Client.GetBucketTagging(params)
	require.NoError(t, err)

	assert.Equal(t, len(taggingOutput.TagSet), 2)
	for _, tag := range taggingOutput.TagSet {
		if *tag.Key == "Name" {
			assert.Equal(t, *tag.Value, testName)
		}
		if *tag.Key == "Test" {
			assert.Equal(t, *tag.Value, "true")
		}
	}
}
