# Ce script génère l'icône SVG de l'app
svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <!-- Fond vert islamique -->
  <rect width="1024" height="1024" rx="200" fill="#1B4332"/>
  
  <!-- Cercle doré décoratif -->
  <circle cx="512" cy="512" r="420" fill="none" stroke="#B7950B" stroke-width="8" opacity="0.4"/>
  <circle cx="512" cy="512" r="380" fill="none" stroke="#B7950B" stroke-width="3" opacity="0.3"/>
  
  <!-- Croissant de lune (symbole islamique) -->
  <path d="M 580 200 
    A 220 220 0 1 0 580 824 
    A 180 180 0 1 1 580 200 Z" 
    fill="#B7950B" opacity="0.9"/>
  
  <!-- Étoile à 8 branches -->
  <g transform="translate(680, 280)" fill="#F9E79F">
    <polygon points="0,-30 8,-8 30,0 8,8 0,30 -8,8 -30,0 -8,-8" opacity="0.9"/>
  </g>

  <!-- Texte arabe القرآن -->
  <text x="512" y="580" 
    font-family="serif" 
    font-size="180" 
    fill="white" 
    text-anchor="middle"
    opacity="0.95">قرآن</text>
    
  <!-- Sous-titre -->
  <text x="512" y="750" 
    font-family="sans-serif" 
    font-size="60" 
    fill="#D8F3DC" 
    text-anchor="middle"
    letter-spacing="4"
    opacity="0.8">APPRENDRE</text>
</svg>'''

with open('app_icon.svg', 'w') as f:
    f.write(svg)
print("SVG généré")
