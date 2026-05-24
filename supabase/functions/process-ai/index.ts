import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { GoogleGenerativeAI } from "https://esm.sh/@google/generative-ai@0.1.3"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

function monetizationContext(value: unknown, targetLang: string): string {
    const text = typeof value === 'string' ? value.trim() : ''
    const normalized = text.toLowerCase().replace(/[^\p{L}\p{N}\s]+/gu, ' ').replace(/\s+/g, ' ').trim()
    const weakAnswers = new Set([
        'idk',
        'i dont know',
        'i don t know',
        'i do not know',
        'not sure',
        'unsure',
        'can you help',
        'please help',
        'help me',
        'tidak tahu',
        'nggak tahu',
        'gak tahu',
        'ga tahu',
        'belum tahu',
        'kurang tahu',
        'bantu saya',
        'tolong bantu',
    ])

    if (!text || weakAnswers.has(normalized)) {
        return targetLang === 'English'
            ? '[blank or weak answer; ignore this field and infer monetization from the other Ikigai answers]'
            : '[jawaban kosong atau lemah; abaikan field ini dan simpulkan monetisasi dari jawaban Ikigai lainnya]'
    }

    return text
}

serve(async (req) => {
    // Handle CORS preflight requests
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { action, payload, language } = await req.json() 
        
        // Default ke Indonesia jika tidak dikirim
        const targetLang = language === 'en' ? 'English' : 'Bahasa Indonesia'; 
        
        // Instruksi Sistem Global
        const systemInstruction = `You are a personal branding expert AI. You MUST generate all content in ${targetLang}. Even if the user input is in a different language, your output must be in ${targetLang}.`
        const apiKey = Deno.env.get('GEMINI_API_KEY')

        if (!apiKey) {
            throw new Error('GEMINI_API_KEY is not set')
        }

        const genAI = new GoogleGenerativeAI(apiKey)
        const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" })

        let prompt = ""

        // --- LOGIC BUILDER PROMPT ---
        if (action === 'generate_identity') {
            const { fullName, whatILove, whatImGoodAt, whatTheWorldNeeds, whatICanBePaidFor } = payload
            const paidForText = monetizationContext(whatICanBePaidFor, targetLang)

            prompt = `
${systemInstruction}
Perkenalkan nama ku: ${fullName}

Saya ingin menemukan niche terbaik yang sesuai dengan Ikigai saya agar saya bisa membangun personal branding yang otentik dan berkelanjutan. Tolong bantu saya mengeksplorasi dan menghubungkan empat elemen utama dari Ikigai saya:

What I Love: ${whatILove}
What I'm Good At: ${whatImGoodAt}
What The World Needs: ${whatTheWorldNeeds}
What I Can Be Paid For (user's original answer, context only): ${paidForText}

Tugas Anda adalah memberikan opsi strategi personal branding yang terpisah agar user bisa memilih sendiri kombinasinya.

PENTING:
Berikan output HANYA dalam format **JSON Object** tunggal dengan 4 array terpisah di dalamnya:
1. \`categories\`: 5 rekomendasi kategori industri yang relevan.
2. \`niches\`: 5 rekomendasi micro-niche dengan kalimat super singkat.
3. \`profile_names\`: 5 nama profil diikuti 2 kata niche TIDAK BOLEH DITAMBAH APA PUN.
4. \`monetization_options\`: 5 saran monetisasi yang disimpulkan dari keseluruhan konteks Ikigai.

Jawaban \`What I Can Be Paid For\` dari user hanya boleh dipakai sebagai konteks. Jangan tulis ulang, jangan refine, dan jangan anggap sebagai nilai final.
Jika jawaban itu kosong atau lemah seperti "idk", "not sure", "can you help", atau "tidak tahu", abaikan jawaban tersebut dan simpulkan \`monetization_options\` dari jawaban Ikigai lainnya.

**CONTOH FORMAT JSON YANG WAJIB DIIKUTI:**
{
  "categories": ["Kategori A", "Kategori B", "Kategori C", "Kategori D", "Kategori E"],
  "niches": ["Micro-Niche 1", "Micro-Niche 2", "Micro-Niche 3", "Micro-Niche 4", "Micro-Niche 5"],
  "profile_names": ["${fullName} | Niche 1", "${fullName} | Niche 2", "${fullName} | Niche 3", "${fullName} | Niche 4", "${fullName} | Niche 5"],
  "monetization_options": ["Saran 1", "Saran 2", "Saran 3", "Saran 4", "Saran 5"]
}

PENTING: Jangan tambahkan teks lain selain JSON di atas. Pastikan setiap array berisi tepat 5 item.
`
        } else if (action === 'generate_premise') {
            const { selectedProfileName, selectedCategory, selectedMicroNiche, strengths, weaknesses, opportunities, threats, userStrengths } = payload
            const finalStrengths = `${userStrengths}, ${strengths}`

            prompt = `
${systemInstruction}
Nama akun dan niche aku "${selectedProfileName}"
Aku ingin membuat premis personal branding yang kuat untuk kategori niche "${selectedCategory}", dan spesifik membahas tentang "${selectedMicroNiche}".

Aku akan memberikan analisis sederhana menggunakan metode SWOT dengan istilah yang mudah dipahami:
KEKUATAN SAYA: ${finalStrengths}
KELEMAHAN SAYA: ${weaknesses}
PELUANG YANG ADA: ${opportunities}
ANCAMAN YANG ADA: ${threats}

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
`
        } else if (action === 'generate_pillars') {
            const { selectedProfileName, selectedCategory, selectedMicroNiche, toneOfVoice, targetAudience, selectedPremise } = payload

            prompt = `
${systemInstruction}
Buatkan daftar Content Pillar yang terdiri dari Educational, Entertain, Inspire, Promote yang lengkap, relevan, dan strategis di sosial media untuk nama akun "${selectedProfileName}", yang mana niche tersebut masuk ke dalam kategori "${selectedCategory}", dan berfokus utama pada "${selectedMicroNiche}" menggunakan tone of voice berikut: "${toneOfVoice}", yang memiliki target audiens "${targetAudience}" dengan menggunakan premisku ini sebagai referensi: "${selectedPremise}"

Berikan jawaban HANYA dalam format seperti contoh di bawah ini. Jangan ubah strukturnya. Jangan gunakan bold text.

DAFTAR CONTENT PILLAR: ${selectedProfileName}

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
`
        } else if (action === 'generate_ideas') {
            const { pillar, ideaCount, selectedProfileName, selectedCategory, selectedMicroNiche, toneOfVoice, targetAudience } = payload

            prompt = `
${systemInstruction}
Buatkan ${ideaCount} ide konten yang lengkap, kreatif, dan strategis untuk akun sosial media "${selectedProfileName}", yang memiliki kategori niche "${selectedCategory}", dengan sub-topik yang membahas tentang "${selectedMicroNiche}". Fokus utama dari konten ini adalah pilar "${pillar}", menggunakan tone of voice berikut: "${toneOfVoice}", yang memiliki target audiens "${targetAudience}". 

Setiap ide harus berisi:
1. **Judul** yang menarik dan clickable
2. **Angle** pendekatan unik untuk topik
3. **Content Overview** ringkasan apa yang akan dibahas
4. **Viral Potential** mengapa ini bisa viral
5. **Insight** value yang didapat audience
6. **Platform** platform media sosial yang paling cocok untuk konten ini (pilih SATU dari: TikTok, Instagram Reels, YouTube Shorts, Instagram Post, LinkedIn Post, atau YouTube Video)

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
`
        } else if (action === 'generate_script') {
            const { idea, platform, selectedProfileName, toneOfVoice, targetAudience } = payload

            prompt = 
`
${systemInstruction}
Buatkan script konten yang siap digunakan untuk platform "${platform}" dengan detail berikut:
- Judul: ${idea.title}
- Angle: ${idea.angle}
- Overview: ${idea.content_overview}
- Platform: ${platform}
- Profil: ${selectedProfileName}
- Tone of Voice: ${toneOfVoice}
- Target Audience: ${targetAudience}

Script harus mengikuti struktur berikut untuk platform ${platform}:

${platform.toLowerCase().includes('tiktok') || platform.toLowerCase().includes('reels') || platform.toLowerCase().includes('shorts') ?
                    `**Format Video Pendek (15-60 detik):**
1. **Hook (0-3 detik)**: Kalimat pembuka yang langsung menarik perhatian
2. **Main Content (4-50 detik)**: Isi utama, dijelaskan dengan jelas dan engaging
3. **Call to Action (51-60 detik)**: Ajakan untuk engage (like, comment, share, follow)` :
                    `**Format Konten Panjang:**
1. **Hook/Opening**: Pembuka yang menarik perhatian
2. **Introduction**: Pengenalan topik dan value proposition
3. **Main Content**: Poin-poin utama yang akan dibahas
4. **Conclusion**: Kesimpulan dan key takeaways
5. **Call to Action**: Ajakan untuk engage`}

Tambahkan juga:
- **Visual Suggestions**: Saran visual/B-roll untuk setiap bagian
- **Hashtags**: 5-10 hashtag relevan untuk ${platform}
- **Music Suggestion**: (jika video) jenis musik yang cocok

Format output dalam teks yang rapi dan siap digunakan, BUKAN dalam format JSON.
`
        } else {
            throw new Error(`Unknown action: ${action}`)
        }

        // --- EXECUTE AI ---
        const result = await model.generateContent(prompt)
        const response = result.response
        const text = response.text()

        return new Response(
            JSON.stringify({ result: text }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
        )

    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
        )
    }
})
