class LanguageFilter < Filter
  # Validations
  validates :identifier, length: { is: 3 }, presence: true, uniqueness: true
  # identifier: ISO 639-2 code (+ additional values)

  # fixed sort (by importance)
  FIXED_IDENTIFIER = %w(deu ara eng fra pol rus tur 150).freeze
  # sorted by german display name
  REMAINING_IDENTIFIER = %w(sqi amh aze ban ben ber bos bul zho 639 fin ell heb
                            hin ita kik kin kor hrv kur lav lit luo ltz mkd hbs
                            568 nor pus fas por rom ron srp skr som snk slo spa
                            swa swe tgk tgl tam tel tha cze tir tuk twi 326 hun
                            urd uzb vie bel wol zza mul).freeze
  IDENTIFIER = FIXED_IDENTIFIER + REMAINING_IDENTIFIER
  enumerize :identifier, in: LanguageFilter::IDENTIFIER
end
