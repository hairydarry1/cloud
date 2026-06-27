# Cloud — Generate 16 Atelier Zero collage images
# Run this AFTER configuring an API key in Settings -> AI Providers
#
# Usage: .\generate-images.ps1
# Requires: An API key configured for one of: Fal.ai (flux-pro-ultra), OpenAI (gpt-image-2)

$model = "flux-pro-ultra"   # Best quality. Requires Fal.ai key.
# $model = "gpt-image-2"    # Alternative. Requires OpenAI key.

$prompts = @{
    "assets/hero.png"          = "Atelier Zero editorial collage of a fashion silhouette — oversized linen duster coat floating against a pale cloud-dream sky, cut-out paper figure in soft grey and cream, coral thread stitching detail, paper texture ground, fragmented composition, warm beige paper backdrop, hand-collaged fabric swatches in corners, surreal scale — 4K editorial fashion collage"
    "assets/about.png"         = "Atelier Zero collage — fashion studio workspace, fabric bolts stacked, paper patterns pinned to wall with coral thread, half-finished linen garment on dress form, warm paper textures layered, sketchbook pages with charcoal drawings, natural light, wooden worktable, tape marks on wall — analogue editorial studio still life, hand-cut paper collage"
    "assets/capabilities.png"  = "Atelier Zero collage grid — four fabric texture studies arranged as a contact sheet, organic cotton weave close-up, linen fiber macro, indigo-dyed swatch, Tencel drape, warm bone paper background dotted grid, hand-written annotations in coral ink, paper cut-out labels, measuring tape curled in corner — materials research editorial spread"
    "assets/lab-1.png"         = "Atelier Zero collage — translucent white linen fabric held up to light, whisper-thin weave visible, paper-cut leaf shapes layered over fabric, warm cream tone, coral stitch detail at edge, micro-texture of linen fibers macro, floating weightless composition on soft beige paper — fabric study editorial"
    "assets/lab-2.png"         = "Atelier Zero collage — five garment pieces arranged in a modular grid pattern, paper cut-out silhouettes of shirt, pant, jacket, vest, skirt in graduated grey tones, coral thread connecting them, overlapping paper layers, shadow depth, warm beige paper ground with dotted grid — modular fashion system editorial collage"
    "assets/lab-3.png"         = "Atelier Zero collage — hand-dipped indigo gradient from deep navy to almost white, fabric submerged in dye bath, paper cut-out wave forms, indigo splatter marks, coral accent thread, watercolor bleed effect on paper texture background, natural indigo pigment study — dye process editorial collage"
    "assets/lab-4.png"         = "Atelier Zero collage — QR code as paper cut-out fragment, ghostly 3D wireframe avatar figure in translucent paper, fabric drape simulation lines, warm paper backdrop, coral highlight dots on scan lines, digital-meets-tactile, hand-collaged interface elements cut from printed paper — tech x fashion editorial"
    "assets/lab-5.png"         = "Atelier Zero collage — plant leaves, bark, organic matter arranged as textural composition, paper cut-out leaf shapes overlapping, biodegradable fabric swatch, natural dye pigments in powder form, coral thread tying samples together, earthy palette (pale brown, cream, sage, rust), hand-made paper texture — sustainable materials editorial"
    "assets/method-1.png"      = "Atelier Zero collage — dreamy architectural sketch, light falling through a tall window, torn paper edges, charcoal figure drawing, paper cut-out cloud shapes, coral thread line tracing a silhouette, warm paper tone, open composition with negative space — design research editorial"
    "assets/method-2.png"      = "Atelier Zero collage — technical fashion sketches on tracing paper layers, pattern pieces in scaled grid, seam detail macro, tailor's shears cutting paper, measuring tape, coral annotation marks, warm beige paper ground with shadow depth — design process editorial still life"
    "assets/method-3.png"      = "Atelier Zero collage — Lisbon atelier workspace, garment on a real body fitting, tailor's hands adjusting fabric, sewing machine in background, natural window light, paper cut-out of torso, fabric draped over chair, warm interior palette — workshop editorial documentary collage"
    "assets/method-4.png"      = "Atelier Zero collage — folded garment wrapped in tissue paper, brown kraft parcel tied with coral string, QR code sticker, handwritten note tag, paper cut-out of shipping label, warm beige background, minimalist still life composition — delivery moment editorial"
    "assets/work-1.png"        = "Atelier Zero fashion editorial — oversized linen duster coat on minimal figure, shoulder to hem continuous seam visible, three pocket detail, fabric drape falling in soft folds, paper cut-out figure against warm beige, coral thread stitch detail near hem, pale grey and cream palette — garment study editorial collage"
    "assets/work-2.png"        = "Atelier Zero fashion editorial — wide-leg double-gauze cotton trouser, leg hem exactly one inch above ground, elastic waistband detail, movement caught mid-stride, paper cut-out figure, warm paper backdrop, coral thread at seam, soft shadow pool on ground — pant drape study editorial collage"
    "assets/testimonial.png"   = "Atelier Zero collage portrait — fashion designer profile, natural light on face, paper cut-out profile silhouette, architectural lines in background, hand-collaged elements (fabric swatch, measuring tape), warm sepia paper tones, coral accent on collar, intimate analogue editorial portrait"
    "assets/cta.png"           = "Atelier Zero editorial collage — abstract composition, sky gradient (pale grey to warm cream) as paper layers, floating fabric piece like cloud, coral thread trailing downward, paper cut-out letters 'Cloud Studio', minimal open space, hand-collaged final plate, warm beige paper texture — closing editorial image"
}

$project = $env:OD_PROJECT_ID
if (-not $project) {
    $project = "9f87e194-146e-45d4-8004-3a6ef410532e"
}

foreach ($file in $prompts.Keys) {
    $prompt = $prompts[$file]
    Write-Host "Generating $file ..." -ForegroundColor Cyan
    
    $out = & $env:OD_NODE_BIN $env:OD_BIN media generate `
        --project $project `
        --surface image `
        --model $model `
        --prompt $prompt `
        --output $file `
        --aspect "4:3" 2>&1
    
    $last = $out | Select-Object -Last 1
    
    if ($last -match '"file"') {
        Write-Host "  ✓ $file generated" -ForegroundColor Green
    } elseif ($last -match 'taskId') {
        Write-Host "  ⏳ Queued, waiting..." -ForegroundColor Yellow
        $taskId = ($last | ConvertFrom-Json).taskId
        while ($true) {
            $status = & $env:OD_NODE_BIN $env:OD_BIN media wait $taskId 2>&1 | Select-Object -Last 1
            if ($status -match '"file"') {
                Write-Host "  ✓ $file done" -ForegroundColor Green
                break
            } elseif ($status -match 'failed') {
                Write-Host "  ✗ $file failed: $status" -ForegroundColor Red
                break
            }
            Start-Sleep -Seconds 10
        }
    } else {
        Write-Host "  ✗ Error: $last" -ForegroundColor Red
    }
}

Write-Host "`nDone. All images generated in assets/." -ForegroundColor Green
