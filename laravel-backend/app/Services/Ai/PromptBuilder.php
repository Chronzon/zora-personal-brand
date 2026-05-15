<?php

namespace App\Services\Ai;

use InvalidArgumentException;

class PromptBuilder
{
    /**
     * @param array<string, mixed> $payload
     */
    public function build(string $action, array $payload, string $language = 'id'): string
    {
        $systemInstruction = $this->systemInstruction($language);

        return match ($action) {
            'generate_identity' => $this->identityPrompt($payload, $systemInstruction, $language),
            'generate_premise' => $this->premisePrompt($payload, $systemInstruction, $language),
            'generate_pillars' => $this->pillarsPrompt($payload, $systemInstruction, $language),
            'generate_ideas' => $this->ideasPrompt($payload, $systemInstruction, $language),
            'generate_script' => $this->scriptPrompt($payload, $systemInstruction, $language),
            default => throw new InvalidArgumentException("Unknown AI action: {$action}"),
        };
    }

    private function systemInstruction(string $language): string
    {
        if ($this->isEnglish($language)) {
            return 'You are a personal branding expert AI. You MUST generate all user-facing content in English only, even if the input is in another language. Keep required JSON property names exactly as specified.';
        }

        return 'You are a personal branding expert AI. You MUST generate all user-facing content in Bahasa Indonesia only, even if the input is in another language. Keep required JSON property names exactly as specified.';
    }

    private function isEnglish(string $language): bool
    {
        return strtolower($language) === 'en';
    }

    /**
     * @param array<string, mixed> $payload
     */
    private function identityPrompt(array $payload, string $systemInstruction, string $language): string
    {
        $fullName = $this->stringValue($payload, 'fullName', 'Personal');
        $paidForText = $this->stringValue($payload, 'whatICanBePaidFor');

        if ($this->isEnglish($language)) {
            $paidForText = $paidForText !== '' ? $paidForText : 'I am not sure yet, please help me discover possible monetization opportunities.';

            return <<<PROMPT
{$systemInstruction}
My name is: {$fullName}

I want to find the best niche that fits my Ikigai so I can build an authentic and sustainable personal brand. Please help me explore and connect the four main elements of my Ikigai:

What I Love: {$this->stringValue($payload, 'whatILove')}
What I'm Good At: {$this->stringValue($payload, 'whatImGoodAt')}
What The World Needs: {$this->stringValue($payload, 'whatTheWorldNeeds')}
What I Can Be Paid For: {$paidForText}

Your task is to provide separate personal branding strategy options so the user can choose their own combination.

IMPORTANT:
Return ONLY one valid JSON object with these 3 separate arrays:
1. `categories`: 5 relevant industry category recommendations.
2. `niches`: 5 micro-niche recommendations with very short phrases.
3. `profile_names`: 5 profile names followed by a 2-word niche. Do not add anything else.

REQUIRED JSON FORMAT:
{
  "categories": ["Category A", "Category B", "Category C", "Category D", "Category E"],
  "niches": ["Micro-Niche 1", "Micro-Niche 2", "Micro-Niche 3", "Micro-Niche 4", "Micro-Niche 5"],
  "profile_names": ["{$fullName} | Niche 1", "{$fullName} | Niche 2", "{$fullName} | Niche 3", "{$fullName} | Niche 4", "{$fullName} | Niche 5"]
}

IMPORTANT: Do not add any text outside the JSON object. Make sure each array contains exactly 5 items.
PROMPT;
        }

        $paidForText = $paidForText !== '' ? $paidForText : 'Aku masih belum tau, tolong dibantu menemukan jawaban untuk peluang monetisasinya';

        return <<<PROMPT
{$systemInstruction}
Perkenalkan nama ku: {$fullName}

Saya ingin menemukan niche terbaik yang sesuai dengan Ikigai saya agar saya bisa membangun personal branding yang otentik dan berkelanjutan. Tolong bantu saya mengeksplorasi dan menghubungkan empat elemen utama dari Ikigai saya:

What I Love: {$this->stringValue($payload, 'whatILove')}
What I'm Good At: {$this->stringValue($payload, 'whatImGoodAt')}
What The World Needs: {$this->stringValue($payload, 'whatTheWorldNeeds')}
What I Can Be Paid For: {$paidForText}

Tugas Anda adalah memberikan opsi strategi personal branding yang terpisah agar user bisa memilih sendiri kombinasinya.

PENTING:
Berikan output HANYA dalam format JSON Object tunggal dengan 3 array terpisah di dalamnya:
1. `categories`: 5 rekomendasi kategori industri yang relevan.
2. `niches`: 5 rekomendasi micro-niche dengan kalimat super singkat.
3. `profile_names`: 5 nama profil diikuti 2 kata niche TIDAK BOLEH DITAMBAH APA PUN.

CONTOH FORMAT JSON YANG WAJIB DIIKUTI:
{
  "categories": ["Kategori A", "Kategori B", "Kategori C", "Kategori D", "Kategori E"],
  "niches": ["Micro-Niche 1", "Micro-Niche 2", "Micro-Niche 3", "Micro-Niche 4", "Micro-Niche 5"],
  "profile_names": ["{$fullName} | Niche 1", "{$fullName} | Niche 2", "{$fullName} | Niche 3", "{$fullName} | Niche 4", "{$fullName} | Niche 5"]
}

PENTING: Jangan tambahkan teks lain selain JSON di atas. Pastikan setiap array berisi tepat 5 item.
PROMPT;
    }

    /**
     * @param array<string, mixed> $payload
     */
    private function premisePrompt(array $payload, string $systemInstruction, string $language): string
    {
        $finalStrengths = trim($this->stringValue($payload, 'userStrengths').', '.$this->stringValue($payload, 'strengths'), ', ');

        if ($this->isEnglish($language)) {
            return <<<PROMPT
{$systemInstruction}
My account name and niche is "{$this->stringValue($payload, 'selectedProfileName')}".
I want to create strong personal branding premises for the niche category "{$this->stringValue($payload, 'selectedCategory')}", specifically about "{$this->stringValue($payload, 'selectedMicroNiche')}".

I will provide a simple SWOT analysis using easy-to-understand terms:
MY STRENGTHS: {$finalStrengths}
MY WEAKNESSES: {$this->stringValue($payload, 'weaknesses')}
OPPORTUNITIES: {$this->stringValue($payload, 'opportunities')}
THREATS: {$this->stringValue($payload, 'threats')}

--- STEP 1: CREATE THE CORE PREMISES (Do this in your reasoning, not in the final answer) ---
Create 10 variations of strong core premise statements.

--- STEP 2: FINAL ANSWER FORMAT ---
Format your answer exactly like the example below.

--- REQUIRED ANSWER FORMAT EXAMPLE ---
Here are 10 personal branding premise options you can use:

1. From Quiet Builder to Trusted Product Partner
"I used to quietly build apps behind the scenes while struggling to explain my own value. Now, I help companies turn unclear product ideas into useful digital tools with practical, human-centered execution."

...continue until 10.
--- END FORMAT EXAMPLE ---
PROMPT;
        }

        return <<<PROMPT
{$systemInstruction}
Nama akun dan niche aku "{$this->stringValue($payload, 'selectedProfileName')}"
Aku ingin membuat premis personal branding yang kuat untuk kategori niche "{$this->stringValue($payload, 'selectedCategory')}", dan spesifik membahas tentang "{$this->stringValue($payload, 'selectedMicroNiche')}".

Aku akan memberikan analisis sederhana menggunakan metode SWOT dengan istilah yang mudah dipahami:
KEKUATAN SAYA: {$finalStrengths}
KELEMAHAN SAYA: {$this->stringValue($payload, 'weaknesses')}
PELUANG YANG ADA: {$this->stringValue($payload, 'opportunities')}
ANCAMAN YANG ADA: {$this->stringValue($payload, 'threats')}

--- LANGKAH 1: PEMBUATAN KALIMAT INTI (Lakukan ini di dalam pikiranmu) ---
Buat 10 variasi kalimat inti.

--- LANGKAH 2: FORMAT JAWABAN AKHIR ---
Format jawabanmu persis seperti contoh di bawah.

--- CONTOH FORMAT JAWABAN ---
Berikut adalah 10 pilihan premis personal branding yang bisa kamu gunakan:

1. Perjalanan dari Pemalu ke Panggung
"Dulu aku adalah seorang introvert yang takut berbicara di depan umum. Namun, aku memutuskan untuk belajar public speaking, hingga akhirnya bisa tampil percaya diri. Kini, aku membimbing orang lain melalui Pelatihan dan Workshop."

...dan seterusnya hingga 10.
--- AKHIR CONTOH FORMAT ---
PROMPT;
    }

    /**
     * @param array<string, mixed> $payload
     */
    private function pillarsPrompt(array $payload, string $systemInstruction, string $language): string
    {
        if ($this->isEnglish($language)) {
            return <<<PROMPT
{$systemInstruction}
Create a complete, relevant, and strategic social media Content Pillar list made of Educational, Entertain, Inspire, and Promote for the account "{$this->stringValue($payload, 'selectedProfileName')}". The niche belongs to the category "{$this->stringValue($payload, 'selectedCategory')}" and focuses on "{$this->stringValue($payload, 'selectedMicroNiche')}". Use this tone of voice: "{$this->stringValue($payload, 'toneOfVoice')}", for this target audience: "{$this->stringValue($payload, 'targetAudience')}", using this premise as reference: "{$this->stringValue($payload, 'selectedPremise')}".

Return the answer ONLY in the format below. Do not change the structure. Do not use bold text.

CONTENT PILLAR LIST: {$this->stringValue($payload, 'selectedProfileName')}

1. Educational (Education: Practical Skills & Expertise)
Why it matters?
- Builds authority around the main niche
- Gives real value to an audience that wants to learn
Sub-topics:
- Beginner-friendly fundamentals
- Common mistakes and how to avoid them
Content Formats:
- Short videos (Reels, TikTok, Shorts)
- Instagram carousel

2. Entertain (Relatable Stories & Light Content)
Why it matters?
- Makes the brand feel human and approachable
- Increases engagement through relatable moments
Sub-topics:
- Behind-the-scenes moments
- Funny or honest lessons from experience
Content Formats:
- Short videos
- Memes or conversational posts

3. Inspire (Transformation & Motivation)
Why it matters?
- Builds emotional connection with the audience
- Shows the bigger reason behind the niche
Sub-topics:
- Personal growth stories
- Audience transformation stories
Content Formats:
- Storytelling videos
- LinkedIn or Instagram posts

4. Promote (Offers & Trust-Building)
Why it matters?
- Turns attention into business opportunities
- Shows clearly how the audience can work with the brand
Sub-topics:
- Services, products, or collaboration offers
- Testimonials, case studies, and proof
Content Formats:
- Sales posts
- Case study videos
PROMPT;
        }

        return <<<PROMPT
{$systemInstruction}
Buatkan daftar Content Pillar yang terdiri dari Educational, Entertain, Inspire, Promote yang lengkap, relevan, dan strategis di sosial media untuk nama akun "{$this->stringValue($payload, 'selectedProfileName')}", yang mana niche tersebut masuk ke dalam kategori "{$this->stringValue($payload, 'selectedCategory')}", dan berfokus utama pada "{$this->stringValue($payload, 'selectedMicroNiche')}" menggunakan tone of voice berikut: "{$this->stringValue($payload, 'toneOfVoice')}", yang memiliki target audiens "{$this->stringValue($payload, 'targetAudience')}" dengan menggunakan premisku ini sebagai referensi: "{$this->stringValue($payload, 'selectedPremise')}"

Berikan jawaban HANYA dalam format seperti contoh di bawah ini. Jangan ubah strukturnya. Jangan gunakan bold text.

DAFTAR CONTENT PILLAR: {$this->stringValue($payload, 'selectedProfileName')}

1. Educational (Edukasi: Public Speaking & Communication Mastery)
Kenapa penting?
- Membangun otoritas sebagai mentor public speaking
- Memberikan value nyata bagi audiens yang ingin belajar
Sub-topik:
- Teknik Dasar Public Speaking untuk Pemula
- Cara Mengatasi Grogi dan Rasa Takut Berbicara di Depan Umum
Format Konten:
- Video pendek (Reels, TikTok, Shorts)
- Carousel Instagram

...
PROMPT;
    }

    /**
     * @param array<string, mixed> $payload
     */
    private function ideasPrompt(array $payload, string $systemInstruction, string $language): string
    {
        if ($this->isEnglish($language)) {
            return <<<PROMPT
{$systemInstruction}
Create {$this->stringValue($payload, 'ideaCount', '5')} complete, creative, and strategic content ideas for the social media account "{$this->stringValue($payload, 'selectedProfileName')}". The account has the niche category "{$this->stringValue($payload, 'selectedCategory')}" and the sub-topic "{$this->stringValue($payload, 'selectedMicroNiche')}". The main focus of these ideas is the "{$this->stringValue($payload, 'pillar')}" pillar, using this tone of voice: "{$this->stringValue($payload, 'toneOfVoice')}", for this target audience: "{$this->stringValue($payload, 'targetAudience')}".

Each idea must include:
1. A compelling, clickable title
2. A unique angle for the topic
3. A content overview that summarizes what will be discussed
4. Viral potential explaining why it could spread
5. The insight or value the audience will gain
6. The best social media platform for the content. Choose ONE from: TikTok, Instagram Reels, YouTube Shorts, Instagram Post, LinkedIn Post, or YouTube Video

Output MUST be a valid JSON array in this format:
[
  {
    "title": "Idea title 1",
    "angle": "Unique angle for idea 1",
    "content_overview": "Overview for idea 1",
    "viral_potential": "Why idea 1 could go viral",
    "insight": "Insight from idea 1",
    "platform": "TikTok"
  }
]

IMPORTANT: Return ONLY valid JSON. Choose a platform that fits the content format and duration.
PROMPT;
        }

        return <<<PROMPT
{$systemInstruction}
Buatkan {$this->stringValue($payload, 'ideaCount', '5')} ide konten yang lengkap, kreatif, dan strategis untuk akun sosial media "{$this->stringValue($payload, 'selectedProfileName')}", yang memiliki kategori niche "{$this->stringValue($payload, 'selectedCategory')}", dengan sub-topik yang membahas tentang "{$this->stringValue($payload, 'selectedMicroNiche')}". Fokus utama dari konten ini adalah pilar "{$this->stringValue($payload, 'pillar')}", menggunakan tone of voice berikut: "{$this->stringValue($payload, 'toneOfVoice')}", yang memiliki target audiens "{$this->stringValue($payload, 'targetAudience')}".

Setiap ide harus berisi:
1. Judul yang menarik dan clickable
2. Angle pendekatan unik untuk topik
3. Content Overview ringkasan apa yang akan dibahas
4. Viral Potential mengapa ini bisa viral
5. Insight value yang didapat audience
6. Platform platform media sosial yang paling cocok untuk konten ini (pilih SATU dari: TikTok, Instagram Reels, YouTube Shorts, Instagram Post, LinkedIn Post, atau YouTube Video)

Output HARUS dalam format JSON array berikut:
[
  {
    "title": "Judul ide 1",
    "angle": "Pendekatan unik ide 1",
    "content_overview": "Overview ide 1",
    "viral_potential": "Alasan viral ide 1",
    "insight": "Insight ide 1",
    "platform": "TikTok"
  }
]

PENTING: Berikan jawabanmu HANYA dalam format JSON yang valid. Pilih platform yang sesuai dengan format dan durasi konten.
PROMPT;
    }

    /**
     * @param array<string, mixed> $payload
     */
    private function scriptPrompt(array $payload, string $systemInstruction, string $language): string
    {
        $idea = $payload['idea'] ?? [];
        $idea = is_array($idea) ? $idea : [];
        $platform = $this->stringValue($payload, 'platform', 'Multi-Platform');
        $platformLower = strtolower($platform);
        $isShortVideo = str_contains($platformLower, 'tiktok') || str_contains($platformLower, 'reels') || str_contains($platformLower, 'shorts');

        if ($this->isEnglish($language)) {
            $format = $isShortVideo
                ? <<<FORMAT
Short Video Format (15-60 seconds):
1. Hook (0-3 seconds): Opening line that grabs attention immediately
2. Main Content (4-50 seconds): Main points explained clearly and engagingly
3. Call to Action (51-60 seconds): Invite the audience to engage (like, comment, share, follow)
FORMAT
                : <<<FORMAT
Long-Form Content Format:
1. Hook/Opening: Attention-grabbing opening
2. Introduction: Topic introduction and value proposition
3. Main Content: Main points to discuss
4. Conclusion: Summary and key takeaways
5. Call to Action: Invite the audience to engage
FORMAT;

            return <<<PROMPT
{$systemInstruction}
Create a ready-to-use content script for the platform "{$platform}" with these details:
- Title: {$this->stringValue($idea, 'title')}
- Angle: {$this->stringValue($idea, 'angle')}
- Overview: {$this->stringValue($idea, 'content_overview')}
- Platform: {$platform}
- Profile: {$this->stringValue($payload, 'selectedProfileName')}
- Tone of Voice: {$this->stringValue($payload, 'toneOfVoice')}
- Target Audience: {$this->stringValue($payload, 'targetAudience')}

The script must follow this structure for {$platform}:

{$format}

Also include:
- Visual Suggestions: Visual or B-roll suggestions for each section
- Hashtags: 5-10 relevant hashtags for {$platform}
- Music Suggestion: If this is video content, suggest a suitable music style

Format the output as clean, ready-to-use text, NOT JSON.
PROMPT;
        }

        $format = $isShortVideo
            ? <<<FORMAT
Format Video Pendek (15-60 detik):
1. Hook (0-3 detik): Kalimat pembuka yang langsung menarik perhatian
2. Main Content (4-50 detik): Isi utama, dijelaskan dengan jelas dan engaging
3. Call to Action (51-60 detik): Ajakan untuk engage (like, comment, share, follow)
FORMAT
            : <<<FORMAT
Format Konten Panjang:
1. Hook/Opening: Pembuka yang menarik perhatian
2. Introduction: Pengenalan topik dan value proposition
3. Main Content: Poin-poin utama yang akan dibahas
4. Conclusion: Kesimpulan dan key takeaways
5. Call to Action: Ajakan untuk engage
FORMAT;

        return <<<PROMPT
{$systemInstruction}
Buatkan script konten yang siap digunakan untuk platform "{$platform}" dengan detail berikut:
- Judul: {$this->stringValue($idea, 'title')}
- Angle: {$this->stringValue($idea, 'angle')}
- Overview: {$this->stringValue($idea, 'content_overview')}
- Platform: {$platform}
- Profil: {$this->stringValue($payload, 'selectedProfileName')}
- Tone of Voice: {$this->stringValue($payload, 'toneOfVoice')}
- Target Audience: {$this->stringValue($payload, 'targetAudience')}

Script harus mengikuti struktur berikut untuk platform {$platform}:

{$format}

Tambahkan juga:
- Visual Suggestions: Saran visual/B-roll untuk setiap bagian
- Hashtags: 5-10 hashtag relevan untuk {$platform}
- Music Suggestion: (jika video) jenis musik yang cocok

Format output dalam teks yang rapi dan siap digunakan, BUKAN dalam format JSON.
PROMPT;
    }

    /**
     * @param array<string, mixed> $payload
     */
    private function stringValue(array $payload, string $key, string $default = ''): string
    {
        $value = $payload[$key] ?? $default;

        if (is_scalar($value)) {
            return (string) $value;
        }

        return $default;
    }
}
