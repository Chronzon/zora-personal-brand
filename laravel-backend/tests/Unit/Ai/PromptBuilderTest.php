<?php

namespace Tests\Unit\Ai;

use App\Services\Ai\PromptBuilder;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

class PromptBuilderTest extends TestCase
{
    public function test_it_builds_prompts_for_all_supported_actions(): void
    {
        $builder = new PromptBuilder;

        $payloads = [
            'generate_identity' => [
                'fullName' => 'Zora',
                'whatILove' => 'Teaching',
                'whatImGoodAt' => 'Explaining ideas',
                'whatTheWorldNeeds' => 'Better learning',
            ],
            'generate_premise' => [
                'selectedProfileName' => 'Zora | Creator Strategy',
                'selectedCategory' => 'Education',
                'selectedMicroNiche' => 'Personal branding',
                'strengths' => 'Clarity',
                'weaknesses' => 'Overthinking',
                'opportunities' => 'Creator economy',
                'threats' => 'Generic content',
                'userStrengths' => 'Systems thinking',
            ],
            'generate_pillars' => [
                'selectedProfileName' => 'Zora | Creator Strategy',
                'selectedCategory' => 'Education',
                'selectedMicroNiche' => 'Personal branding',
                'toneOfVoice' => 'Warm',
                'targetAudience' => 'New creators',
                'selectedPremise' => 'Helping creators become clear.',
            ],
            'generate_ideas' => [
                'pillar' => 'Educational',
                'ideaCount' => 3,
                'selectedProfileName' => 'Zora | Creator Strategy',
                'selectedCategory' => 'Education',
                'selectedMicroNiche' => 'Personal branding',
                'toneOfVoice' => 'Warm',
                'targetAudience' => 'New creators',
            ],
            'generate_script' => [
                'idea' => [
                    'title' => 'One clear niche',
                    'angle' => 'Simple framework',
                    'content_overview' => 'Explain niche clarity.',
                ],
                'platform' => 'TikTok',
                'selectedProfileName' => 'Zora | Creator Strategy',
                'toneOfVoice' => 'Warm',
                'targetAudience' => 'New creators',
            ],
        ];

        foreach ($payloads as $action => $payload) {
            $prompt = $builder->build($action, $payload, 'id');

            $this->assertStringContainsString('Bahasa Indonesia', $prompt);
            $this->assertStringContainsString('personal branding expert AI', $prompt);
            $this->assertNotSame('', trim($prompt));
        }
    }

    public function test_it_maps_english_language(): void
    {
        $prompt = (new PromptBuilder)->build('generate_identity', [
            'fullName' => 'Zora',
        ], 'en');

        $this->assertStringContainsString('English', $prompt);
        $this->assertStringContainsString('Return ONLY one valid JSON object', $prompt);
        $this->assertStringContainsString('"categories"', $prompt);
        $this->assertStringContainsString('"profile_names"', $prompt);
        $this->assertStringContainsString('"monetization_options"', $prompt);
        $this->assertStringNotContainsString('Bahasa Indonesia', $prompt);
        $this->assertStringNotContainsString('PENTING', $prompt);
    }

    public function test_identity_prompt_requires_separate_monetization_options(): void
    {
        $prompt = (new PromptBuilder)->build('generate_identity', [
            'fullName' => 'Zora',
            'whatILove' => 'Teaching',
            'whatImGoodAt' => 'Explaining ideas',
            'whatTheWorldNeeds' => 'Better learning',
            'whatICanBePaidFor' => 'Workshops',
        ], 'en');

        $this->assertStringContainsString('`monetization_options`: 5 monetization suggestions', $prompt);
        $this->assertStringContainsString('"monetization_options"', $prompt);
        $this->assertStringContainsString('context only', $prompt);
        $this->assertStringContainsString('Do not rewrite it', $prompt);
        $this->assertStringContainsString('What I Can Be Paid For (user\'s original answer, context only): Workshops', $prompt);
    }

    public function test_identity_prompt_ignores_blank_monetization_input(): void
    {
        $prompt = (new PromptBuilder)->build('generate_identity', [
            'fullName' => 'Zora',
            'whatILove' => 'Teaching',
            'whatImGoodAt' => 'Explaining ideas',
            'whatTheWorldNeeds' => 'Better learning',
            'whatICanBePaidFor' => '',
        ], 'en');

        $this->assertStringContainsString('blank or weak answer', $prompt);
        $this->assertStringContainsString('ignore this field and infer monetization', $prompt);
        $this->assertStringNotContainsString('I am not sure yet, please help me discover possible monetization opportunities.', $prompt);
    }

    public function test_identity_prompt_ignores_weak_monetization_input(): void
    {
        $prompt = (new PromptBuilder)->build('generate_identity', [
            'fullName' => 'Zora',
            'whatILove' => 'Teaching',
            'whatImGoodAt' => 'Explaining ideas',
            'whatTheWorldNeeds' => 'Better learning',
            'whatICanBePaidFor' => 'tidak tahu',
        ], 'id');

        $this->assertStringContainsString('jawaban kosong atau lemah', $prompt);
        $this->assertStringContainsString('abaikan field ini', $prompt);
        $this->assertStringNotContainsString('Aku masih belum tau, tolong dibantu menemukan jawaban untuk peluang monetisasinya', $prompt);
    }

    public function test_english_prompts_use_english_templates_for_all_actions(): void
    {
        $builder = new PromptBuilder;

        $payload = [
            'fullName' => 'Zora',
            'whatILove' => 'Teaching',
            'whatImGoodAt' => 'Explaining ideas',
            'whatTheWorldNeeds' => 'Better learning',
            'whatICanBePaidFor' => 'Workshops',
            'selectedProfileName' => 'Zora | Creator Strategy',
            'selectedCategory' => 'Education',
            'selectedMicroNiche' => 'Personal branding',
            'strengths' => 'Clarity',
            'weaknesses' => 'Overthinking',
            'opportunities' => 'Creator economy',
            'threats' => 'Generic content',
            'userStrengths' => 'Systems thinking',
            'toneOfVoice' => 'Warm',
            'targetAudience' => 'New creators',
            'selectedPremise' => 'Helping creators become clear.',
            'pillar' => 'Educational',
            'ideaCount' => 3,
            'platform' => 'TikTok',
            'idea' => [
                'title' => 'One clear niche',
                'angle' => 'Simple framework',
                'content_overview' => 'Explain niche clarity.',
            ],
        ];

        foreach (['generate_identity', 'generate_premise', 'generate_pillars', 'generate_ideas', 'generate_script'] as $action) {
            $prompt = $builder->build($action, $payload, 'en');

            $this->assertStringContainsString('English', $prompt);
            $this->assertStringNotContainsString('Bahasa Indonesia', $prompt);
            $this->assertStringNotContainsString('PENTING', $prompt);
            $this->assertStringNotContainsString('Buatkan', $prompt);
            $this->assertStringNotContainsString('Berikut adalah', $prompt);
            $this->assertStringNotContainsString('KEKUATAN SAYA', $prompt);
        }
    }

    public function test_it_rejects_unknown_actions(): void
    {
        $this->expectException(InvalidArgumentException::class);

        (new PromptBuilder)->build('unknown_action', [], 'id');
    }
}
