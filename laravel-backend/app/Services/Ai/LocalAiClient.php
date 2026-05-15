<?php

namespace App\Services\Ai;

class LocalAiClient implements AiClientInterface
{
    /**
     * @param array<string, mixed> $context
     */
    public function generate(string $prompt, array $context = []): string
    {
        $action = is_string($context['action'] ?? null) ? $context['action'] : 'unknown';
        $payload = is_array($context['payload'] ?? null) ? $context['payload'] : [];

        return match ($action) {
            'generate_identity' => json_encode([
                'profile_names' => [
                    ($payload['fullName'] ?? 'Personal').' Growth Lab',
                    'Authentic Builder',
                    'Niche Authority',
                ],
                'categories' => ['Education', 'Personal Development', 'Digital Creator'],
                'niches' => ['Career storytelling', 'Practical self-improvement', 'Creator education'],
            ], JSON_PRETTY_PRINT),
            'generate_premise' => "1. \"Helping ambitious beginners build a practical personal brand from their real skills.\"\n\n2. \"Turning everyday expertise into useful content that earns trust.\"\n\n3. \"A clear, honest guide for people who want to grow online without pretending.\"",
            'generate_pillars' => "1. Personal Story\n2. Practical Tutorials\n3. Industry Insight\n4. Audience Q&A",
            'generate_ideas' => json_encode([
                [
                    'title' => 'The mistake I made when choosing my niche',
                    'angle' => 'Personal lesson with a practical correction',
                    'content_overview' => 'Tell the story, explain the mistake, then give a three-step way to choose a clearer niche.',
                    'viral_potential' => 'Medium',
                    'insight' => 'Specific mistakes make advice more believable.',
                    'platform' => 'Multi-Platform',
                ],
                [
                    'title' => 'One simple framework for your next content idea',
                    'angle' => 'Actionable tutorial',
                    'content_overview' => 'Show a before/after example using problem, proof, process, and prompt.',
                    'viral_potential' => 'High',
                    'insight' => 'Framework content is easy to save and reuse.',
                    'platform' => 'Multi-Platform',
                ],
            ], JSON_PRETTY_PRINT),
            'generate_script' => "Hook: Most people make personal branding harder than it needs to be.\n\nBody: Start with one problem your audience already feels. Share one useful lesson from your own experience. Then give them one action they can try today.\n\nCTA: Save this and use it for your next post.",
            default => 'Local AI stub is running. Add a real provider configuration when ready.',
        };
    }
}

