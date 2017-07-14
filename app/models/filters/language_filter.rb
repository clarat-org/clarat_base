class LanguageFilter < Filter
  # Associations
  has_many :offers, through: :filters_offers
  # Validations moved to claradmin
  # identifier: ISO 639-2 code (+ additional values)
  # sorted by german display name
  IDENTIFIER = %w(cau aar sqi abk amh ara arc arm aze ban bam ben ber bos bul
                  bur zho 639 deu 150 dyu dan eng est ewe ewo fil fin fra ful
                  gej geo ell hau heb hin ita cpe kik kin run kor hrv kur sdh
                  xxx lav lin lit luo ltz msa man mkd hbs mos 568 nor pan pus
                  fas pol por fuf rom ron srp skr slo slv som snk ckb spa sus
                  swa rus swe cus tgk tgl tam tel tha tig tir cze tur tuk twi
                  326 hun urd uzb vie bel wol dje zza mul).freeze
  enumerize :identifier, in: LanguageFilter::IDENTIFIER
end
