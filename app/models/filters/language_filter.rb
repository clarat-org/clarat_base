class LanguageFilter < Filter
  # Validations
  validates :identifier, length: { is: 3 }, presence: true, uniqueness: true
  # identifier: ISO 639-2 code (+ additional values)

  # sorted by german display name
  IDENTIFIER = %w(cau sqi amh ara arc aze ban bam ben ber bos bul zho 639 deu
                  150 dyu eng ewo fin fra ell heb hin ita cpe kik kin kor hrv
                  kur lav lit luo ltz man mkd hbs 568 nor pus fas pol por rom
                  ron srp skr slo slv som snk spa swa rus swe tgk tgl tam tel
                  tha tir cze tur tuk twi 326 hun urd uzb vie bel wol zza mul
                  ).freeze
  enumerize :identifier, in: LanguageFilter::IDENTIFIER
end
