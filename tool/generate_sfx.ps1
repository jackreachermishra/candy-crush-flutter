# Synthesizes original mono PCM tones. No third-party audio is used.
$ErrorActionPreference = 'Stop'
$sampleRate = 22050
$sounds = @(
    @{ Name = 'select'; Start = 740; End = 960; Ms = 90; Notes = @() },
    @{ Name = 'invalid'; Start = 310; End = 220; Ms = 160; Notes = @() },
    @{ Name = 'swap'; Start = 560; End = 840; Ms = 130; Notes = @() },
    @{ Name = 'move_down'; Start = 460; End = 680; Ms = 115; Notes = @() },
    @{ Name = 'bomb'; Start = 250; End = 75; Ms = 280; Notes = @() },
    @{ Name = 'game_start'; Start = 440; End = 660; Ms = 230; Notes = @(440, 554, 660) },
    @{ Name = 'win'; Start = 523; End = 784; Ms = 420; Notes = @(523, 659, 784) },
    @{ Name = 'lost'; Start = 392; End = 262; Ms = 350; Notes = @(392, 330, 262) }
)
$output = Join-Path $PSScriptRoot '..\assets\audio'
foreach ($sound in $sounds) {
    $count = [int]($sampleRate * $sound.Ms / 1000)
    $path = Join-Path $output ($sound.Name + '.wav')
    $stream = [System.IO.File]::Open($path, [System.IO.FileMode]::Create)
    $writer = New-Object System.IO.BinaryWriter($stream)
    try {
        $writer.Write([System.Text.Encoding]::ASCII.GetBytes('RIFF'))
        $writer.Write([int](36 + $count * 2))
        $writer.Write([System.Text.Encoding]::ASCII.GetBytes('WAVEfmt '))
        $writer.Write([int]16)
        $writer.Write([int16]1)
        $writer.Write([int16]1)
        $writer.Write([int]$sampleRate)
        $writer.Write([int]($sampleRate * 2))
        $writer.Write([int16]2)
        $writer.Write([int16]16)
        $writer.Write([System.Text.Encoding]::ASCII.GetBytes('data'))
        $writer.Write([int]($count * 2))
        $phase = 0.0
        for ($i = 0; $i -lt $count; $i++) {
            $t = $i / $count
            $frequency = $sound.Start + ($sound.End - $sound.Start) * $t
            if ($sound.Notes.Count -gt 0) {
                $note = [Math]::Min($sound.Notes.Count - 1, [int][Math]::Floor($t * $sound.Notes.Count))
                $frequency = $sound.Notes[$note]
            }
            $phase += 2 * [Math]::PI * $frequency / $sampleRate
            $attack = [Math]::Min(1, $t * 35)
            $envelope = $attack * [Math]::Pow(1 - $t, 1.8)
            $wave = [Math]::Sin($phase) + 0.16 * [Math]::Sin(2 * $phase)
            $sample = [int16]([Math]::Round(9000 * $envelope * $wave))
            $writer.Write($sample)
        }
    } finally {
        $writer.Dispose()
        $stream.Dispose()
    }
}
