class FlagUtils {

  static String flagEmoji(
    String code,
  ) {
    const flags = {

      'ESP': '🇪🇸',
      'FRA': '🇫🇷',
      'GER': '🇩🇪',
      'ITA': '🇮🇹',
      'POR': '🇵🇹',
      'ENG': '🏴\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}',

      'ARG': '🇦🇷',
      'BRA': '🇧🇷',
      'URU': '🇺🇾',
      'COL': '🇨🇴',
      'MEX': '🇲🇽',
      'USA': '🇺🇸',
      'CAN': '🇨🇦',

      'JPN': '🇯🇵',
      'KOR': '🇰🇷',
      'AUS': '🇦🇺',

      'MAR': '🇲🇦',
      'SEN': '🇸🇳',
      'NGA': '🇳🇬',
      'EGY': '🇪🇬',
      'TUN': '🇹🇳',

      'NED': '🇳🇱',
      'BEL': '🇧🇪',
      'SUI': '🇨🇭',
      'DEN': '🇩🇰',
      'SWE': '🇸🇪',
      'NOR': '🇳🇴',
      'POL': '🇵🇱',
      'CRO': '🇭🇷',
      'SRB': '🇷🇸',
      'AUT': '🇦🇹',
      'CZE': '🇨🇿',
      'UKR': '🇺🇦',
      'TUR': '🇹🇷',

      'CHI': '🇨🇱',
      'PER': '🇵🇪',
      'ECU': '🇪🇨',
      'PAR': '🇵🇾',
      'VEN': '🇻🇪',

      'CRC': '🇨🇷',
      'HON': '🇭🇳',
      'PAN': '🇵🇦',

      'IRN': '🇮🇷',
      'KSA': '🇸🇦',
      'QAT': '🇶🇦',
      'UAE': '🇦🇪',

      'NZL': '🇳🇿',

       'RSA': '🇿🇦', // Sudáfrica
        'CIV': '🇨🇮', // Costa de Marfil
        'CPV': '🇨🇻', // Cabo Verde
        'GHA': '🇬🇭', // Ghana
        'ALG': '🇩🇿', // Argelia
        'COD': '🇨🇩',
        'BIH': '🇧🇦', // Bosnia y Herzegovina
        'SCO': '🏴\u{E0067}\u{E0062}\u{E0073}\u{E0063}\u{E0074}\u{E007F}',   // Escocia
        'HAI': '🇭🇹', // Haití
        'CUW': '🇨🇼', // Curazao

        'IRQ': '🇮🇶', // Irak
        'JOR': '🇯🇴', // Jordania
        'UZB': '🇺🇿', // Uzbekistán






      'España': '🇪🇸',
      'Francia': '🇫🇷',
      'Alemania': '🇩🇪',
      'Portugal': '🇵🇹',
      'Inglaterra': '🏴\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}',

      'Argentina': '🇦🇷',
      'Brasil': '🇧🇷',
      'Uruguay': '🇺🇾',
      'Colombia': '🇨🇴',
      'México': '🇲🇽',
      'Estados Unidos': '🇺🇸',
      'Canadá': '🇨🇦',

      'Japón': '🇯🇵',
      'Corea del Sur': '🇰🇷',
      'Australia': '🇦🇺',

      'Marruecos': '🇲🇦',
      'Senegal': '🇸🇳',
      'Egipto': '🇪🇬',
      'Túnez': '🇹🇳',

      'Países Bajos': '🇳🇱',
      'Bélgica': '🇧🇪',
      'Suiza': '🇨🇭',
      'Suecia': '🇸🇪',
      'Noruega': '🇳🇴',
      'Croacia': '🇭🇷',
      'Austria': '🇦🇹',
      'Chequia': '🇨🇿',
      'Turquía': '🇹🇷',

      'Ecuador': '🇪🇨',
      'Paraguay': '🇵🇾',

      'Panamá': '🇵🇦',

      'Irán': '🇮🇷',
      'Arabia Saudí': '🇸🇦',
      'Catar': '🇶🇦',

      'Nueva Zelanda': '🇳🇿',

       'Sudáfrica': '🇿🇦', // Sudáfrica
        'Costa de Marfil': '🇨🇮', // Costa de Marfil
        'Cabo Verde': '🇨🇻', // Cabo Verde
        'Ghana': '🇬🇭', // Ghana
        'Argelia': '🇩🇿', // Argelia
        'RD Congo': '🇨🇩',
        'Bosnia y Herzegovina': '🇧🇦', // Bosnia y Herzegovina
        'Escocia': '🏴\u{E0067}\u{E0062}\u{E0073}\u{E0063}\u{E0074}\u{E007F}',   // Escocia
        'Haití': '🇭🇹', // Haití
        'Curazao': '🇨🇼', // Curazao

        'Irak': '🇮🇶', // Irak
        'Jordania': '🇯🇴', // Jordania
        'Uzbekistán': '🇺🇿', // Uzbekistán
    };

    return flags[code] ?? '🏳️';
  }
}