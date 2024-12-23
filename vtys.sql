--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2024-12-21 18:19:38

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 16732)
-- Name: Calisan; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "Calisan";


ALTER SCHEMA "Calisan" OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 16866)
-- Name: calisanlar_insert_trigger(); Type: FUNCTION; Schema: Calisan; Owner: postgres
--

CREATE FUNCTION "Calisan".calisanlar_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    -- Eğer veri ebeveyn tablodaysa ve ilgili çocuk tabloya eklenmesi gerekiyorsa
    IF TG_TABLE_NAME = 'calisan' THEN
        -- Eğer gorevTuru 'Şoför' ise, sofor tablosuna ekle
	    IF NEW.gorevturu = 'sofor' THEN
	        INSERT INTO soforler (calisanİd, bolumİd, ad, soyad, gorevturu, maas,departman ,deneyim, aractipi, aracId)
	        VALUES (NEW.calisanİd, NEW.bolumİd, NEW.ad, NEW.soyad, NEW.gorevturu, NEW.maas, new.departman, NEW.deneyim, new.aractipi, new.aracId);
	
	    -- Eğer gorevTuru 'Müdür' ise, mudurler tablosuna ekleme yap
	    ELSIF NEW.gorevturu = 'mudur' THEN
	        INSERT INTO mudurler (calisanİd, bolumİd, ad, soyad, gorevturu, maas, departman, deneyim, aractipi, aracId)
	        VALUES (NEW.calisanİd, NEW.bolumİd, NEW.ad, NEW.soyad, NEW.gorevturu, NEW.maas, NEW.departman, NEW.deneyim,null,null);
	
	    -- Eğer gorevTuru 'Depo Çalışanı' ise, depocalisanlar tablosuna ekleme yap
	    ELSIF NEW.gorevturu = 'depocalisan' THEN
	        INSERT INTO depocalisanlar (calisanİd, bolumİd, ad, soyad, gorevturu, maas, departman, deneyim, aractipi, aracId)
	        VALUES (NEW.calisanİd, NEW.bolumİd, NEW.ad, NEW.soyad, NEW.gorevturu, NEW.maas, NEW.departman, NEW.deneyim,null,null);

        END IF;
    END IF;

    -- NEW kaydını geri döndür
    RETURN NEW;
END;

$$;


ALTER FUNCTION "Calisan".calisanlar_insert_trigger() OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 16842)
-- Name: maas_kontrol(); Type: FUNCTION; Schema: Calisan; Owner: postgres
--

CREATE FUNCTION "Calisan".maas_kontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    IF NEW.maas < 5000 THEN
        RAISE EXCEPTION 'Maas 5000 TL''den kucuk olamaz';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "Calisan".maas_kontrol() OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 16874)
-- Name: siparis_durum_ogren(integer, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparis_durum_ogren(siparisno integer, istenilentarih date) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE 
    siparistarihi DATE;
    tarihfarki INTEGER;
BEGIN
    SELECT tarih INTO siparistarihi
    FROM sevkiyat 
    WHERE "siparisNo" = siparisno;

    tarihfarki := istenilentarih - siparistarihi;

    IF tarihfarki > 0 THEN
        RETURN 'Yolda';
    ELSIF tarihfarki = 0 THEN
        RETURN 'Teslim Edildi';
	ELSE 
		return 'girilen tarih siparis tarihinden önce';
    END IF;
END;
$$;


ALTER FUNCTION public.siparis_durum_ogren(siparisno integer, istenilentarih date) OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 16891)
-- Name: siparisler_sira(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparisler_sira(siparis_veren_no integer) RETURNS TABLE(urunadi text, fiyat integer)
    LANGUAGE plpgsql
    AS $$
begin
	return query select "siparisAdı","tutar" from "siparisurun" 
	where "siparisveren" = siparis_veren_no order by  "tutar" desc;
end;
$$;


ALTER FUNCTION public.siparisler_sira(siparis_veren_no integer) OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 16831)
-- Name: siparistoplamtutar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparistoplamtutar() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	NEW."tutar" := NEW."birimFiyat" * NEW."siparisadet";
	return new;
end;
$$;


ALTER FUNCTION public.siparistoplamtutar() OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 16829)
-- Name: siparisurunarttir(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparisurunarttir() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	declare
		s_adet integer;
begin
s_adet:= (select siparisadet from siparisurun order by "siparisNo" desc limit 1);
update urun set stok = stok+s_adet;
return new;
end;
$$;


ALTER FUNCTION public.siparisurunarttir() OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 16892)
-- Name: stok_durumu_kontrol(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.stok_durumu_kontrol(urun_kod integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    stok_miktari INTEGER;
BEGIN
    SELECT "stok" INTO stok_miktari
    FROM "urun"
    WHERE "urunKodu" = urun_kod;

    IF stok_miktari IS NULL THEN
        RETURN 'Ürün bulunamadı';
    ELSIF stok_miktari = 0 THEN
        RETURN 'Stokta ürün yok';
    ELSE
        RETURN 'Stok miktarı: ' || stok_miktari;
    END IF;
END;
$$;


ALTER FUNCTION public.stok_durumu_kontrol(urun_kod integer) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 16893)
-- Name: stoktan_urun_cikar(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.stoktan_urun_cikar(urun_kod integer, miktar integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    mevcut_stok INTEGER;
BEGIN
    SELECT stok INTO mevcut_stok
    FROM "urun"
    WHERE "urunKodu" = urun_kod;

    IF mevcut_stok IS NULL THEN
        RETURN 'Ürün bulunamadı';
    ELSIF mevcut_stok < miktar THEN
        RETURN 'Yetersiz stok';
    ELSE
        UPDATE "urun"
        SET "stok" = "stok" - miktar
        WHERE "urunKodu" = urun_kod;

        RETURN 'Stok güncellendi. Kalan stok: ' || (mevcut_stok - miktar);
    END IF;
END;
$$;


ALTER FUNCTION public.stoktan_urun_cikar(urun_kod integer, miktar integer) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 16837)
-- Name: yakitmaliyethesabi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.yakitmaliyethesabi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	begin
	NEW."yakıtmaliyet" := NEW."yakitfiyati" * NEW."tüketilenyakıt" ;
	return new;
end;
$$;


ALTER FUNCTION public.yakitmaliyethesabi() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 229 (class 1259 OID 16733)
-- Name: calisan; Type: TABLE; Schema: Calisan; Owner: postgres
--

CREATE TABLE "Calisan".calisan (
    "calisanİd" serial NOT NULL,
    "bolumİd" integer NOT NULL,
    ad text NOT NULL,
    soyad text NOT NULL,
    gorevturu text,
    maas integer,
    departman character varying(100),
    deneyim integer,
    aracid integer,
    aractipi text,
    CONSTRAINT check_gorevturu CHECK ((gorevturu = ANY (ARRAY['sofor'::text, 'mudur'::text, 'depocalisan'::text])))
    CONSTRAINT calisan_pkey PRIMARY KEY (calisanİd)
);


ALTER TABLE "Calisan".calisan OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16894)
-- Name: calisan_calisanİd_seq; Type: SEQUENCE; Schema: Calisan; Owner: postgres
--

ALTER TABLE "Calisan".calisan ALTER COLUMN "calisanİd" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "Calisan"."calisan_calisanİd_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 226 (class 1259 OID 16589)
-- Name: arac; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.arac (
    "aracİd" integer NOT NULL,
    "aracTipi" text NOT NULL
);


ALTER TABLE public.arac OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16895)
-- Name: arac_aracİd_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.arac ALTER COLUMN "aracİd" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."arac_aracİd_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 220 (class 1259 OID 16441)
-- Name: depo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.depo (
    "depoİd" integer NOT NULL,
    "ilceNo" integer NOT NULL,
    "depoAdı" text,
    kapasite integer DEFAULT 0
);


ALTER TABLE public.depo OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16896)
-- Name: depo_depoİd_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.depo ALTER COLUMN "depoİd" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."depo_depoİd_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 230 (class 1259 OID 16797)
-- Name: depobakım; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."depobakım" (
    "depoİd" integer NOT NULL,
    "bakımmaliyet" integer NOT NULL,
    "bakımtür" text NOT NULL,
    "bakımtarih" date NOT NULL
);


ALTER TABLE public."depobakım" OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16510)
-- Name: depobolum; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.depobolum (
    "bolumİd" integer NOT NULL,
    "depoİd" integer NOT NULL,
    "kategoriİd" integer NOT NULL,
    kapasite integer DEFAULT 0,
    "bolumAdı" text
);


ALTER TABLE public.depobolum OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 16897)
-- Name: depobolum_bolumİd_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.depobolum ALTER COLUMN "bolumİd" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."depobolum_bolumİd_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 234 (class 1259 OID 16858)
-- Name: depocalisanlar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.depocalisanlar (
    departman character varying(100),
    deneyim integer
)
INHERITS ("Calisan".calisan);


ALTER TABLE public.depocalisanlar OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16477)
-- Name: fatura; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fatura (
    "faturaNo" integer NOT NULL,
    "faturaTarihi" date
);


ALTER TABLE public.fatura OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16421)
-- Name: il; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.il (
    "ilAdı" text NOT NULL,
    "ilNo" integer NOT NULL
);


ALTER TABLE public.il OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16428)
-- Name: ilce; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ilce (
    "ilceAdi" text NOT NULL,
    "ilceNo" integer NOT NULL,
    "ilNo" integer NOT NULL
);


ALTER TABLE public.ilce OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16455)
-- Name: kategori; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kategori (
    "kategoriİd" integer NOT NULL,
    kategoriadi text NOT NULL
);


ALTER TABLE public.kategori OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16898)
-- Name: kategori_kategoriİd_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.kategori ALTER COLUMN "kategoriİd" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."kategori_kategoriİd_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 233 (class 1259 OID 16852)
-- Name: mudurler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mudurler (
    departman character varying(100),
    deneyim integer
)
INHERITS ("Calisan".calisan);


ALTER TABLE public.mudurler OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16644)
-- Name: sevkiyat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sevkiyat (
    "siparisNo" integer NOT NULL,
    "depoİd" integer NOT NULL,
    "aracİd" integer NOT NULL,
    tarih date NOT NULL
);


ALTER TABLE public.sevkiyat OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16482)
-- Name: siparisurun; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.siparisurun (
    "urunKodu" integer NOT NULL,
    "siparisAdı" text,
    "siparisNo" integer NOT NULL,
    "birimFiyat" integer DEFAULT 0,
    "faturaNo" integer NOT NULL,
    siparisadet integer,
    tutar integer,
    siparisveren integer
);


ALTER TABLE public.siparisurun OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 16899)
-- Name: siparisurun_siparisNo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.siparisurun ALTER COLUMN "siparisNo" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."siparisurun_siparisNo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 232 (class 1259 OID 16846)
-- Name: soforler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.soforler (
    deneyim integer,
    aractipi text,
    aracid integer
)
INHERITS ("Calisan".calisan);


ALTER TABLE public.soforler OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16698)
-- Name: tedarikci; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tedarikci (
    "tedarikciİd" integer NOT NULL,
    "ilceNo" integer NOT NULL,
    "kategoriİd" integer NOT NULL,
    "telefonNo" "char" NOT NULL,
    ad text,
    CONSTRAINT "tedarikci.telefonNo = 10" CHECK (true)
);


ALTER TABLE public.tedarikci OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 16900)
-- Name: tedarikci_tedarikciİd_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tedarikci ALTER COLUMN "tedarikciİd" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."tedarikci_tedarikciİd_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 222 (class 1259 OID 16462)
-- Name: urun; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.urun (
    urunadi text NOT NULL,
    stok integer DEFAULT 0,
    "kategoriİd" integer NOT NULL,
    "birimFiyat" integer DEFAULT 0,
    "urunKodu" integer NOT NULL
);


ALTER TABLE public.urun OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16809)
-- Name: yakitTuketim; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."yakitTuketim" (
    "kayıtİd" integer NOT NULL,
    "aracİd" integer NOT NULL,
    tarih date NOT NULL,
    gidilenmesafe integer,
    "tüketilenyakıt" integer,
    "yakıtmaliyet" integer DEFAULT 40,
    yakitfiyati integer DEFAULT 20
);


ALTER TABLE public."yakitTuketim" OWNER TO postgres;

--
-- TOC entry 5017 (class 0 OID 16733)
-- Dependencies: 229
-- Data for Name: calisan; Type: TABLE DATA; Schema: Calisan; Owner: postgres
--

COPY "Calisan".calisan ("calisanİd", "bolumİd", ad, soyad, gorevturu, maas, departman, deneyim, aracid, aractipi) FROM stdin;
\.


--
-- TOC entry 5014 (class 0 OID 16589)
-- Dependencies: 226
-- Data for Name: arac; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.arac ("aracİd", "aracTipi") FROM stdin;
1	tır
2	kamyon
3	minibüs
\.


--
-- TOC entry 5008 (class 0 OID 16441)
-- Dependencies: 220
-- Data for Name: depo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.depo ("depoİd", "ilceNo", "depoAdı", kapasite) FROM stdin;
1	1	soguk	100
2	1	sicak	200
\.


--
-- TOC entry 5018 (class 0 OID 16797)
-- Dependencies: 230
-- Data for Name: depobakım; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."depobakım" ("depoİd", "bakımmaliyet", "bakımtür", "bakımtarih") FROM stdin;
\.


--
-- TOC entry 5013 (class 0 OID 16510)
-- Dependencies: 225
-- Data for Name: depobolum; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.depobolum ("bolumİd", "depoİd", "kategoriİd", kapasite, "bolumAdı") FROM stdin;
1	1	1	50	dondurma
2	2	1	50	tavuk
\.


--
-- TOC entry 5022 (class 0 OID 16858)
-- Dependencies: 234
-- Data for Name: depocalisanlar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.depocalisanlar ("calisanİd", "bolumİd", ad, soyad, gorevturu, maas, departman, deneyim, aracid, aractipi) FROM stdin;
\.


--
-- TOC entry 5011 (class 0 OID 16477)
-- Dependencies: 223
-- Data for Name: fatura; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fatura ("faturaNo", "faturaTarihi") FROM stdin;
1	2024-12-16
\.


--
-- TOC entry 5006 (class 0 OID 16421)
-- Dependencies: 218
-- Data for Name: il; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.il ("ilAdı", "ilNo") FROM stdin;
sakarya	1
\.


--
-- TOC entry 5007 (class 0 OID 16428)
-- Dependencies: 219
-- Data for Name: ilce; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ilce ("ilceAdi", "ilceNo", "ilNo") FROM stdin;
serdivan	1	1
\.


--
-- TOC entry 5009 (class 0 OID 16455)
-- Dependencies: 221
-- Data for Name: kategori; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kategori ("kategoriİd", kategoriadi) FROM stdin;
1	kuruyemiş
\.


--
-- TOC entry 5021 (class 0 OID 16852)
-- Dependencies: 233
-- Data for Name: mudurler; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mudurler ("calisanİd", "bolumİd", ad, soyad, gorevturu, maas, departman, deneyim, aracid, aractipi) FROM stdin;
\.


--
-- TOC entry 5015 (class 0 OID 16644)
-- Dependencies: 227
-- Data for Name: sevkiyat; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sevkiyat ("siparisNo", "depoİd", "aracİd", tarih) FROM stdin;
\.


--
-- TOC entry 5012 (class 0 OID 16482)
-- Dependencies: 224
-- Data for Name: siparisurun; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.siparisurun ("urunKodu", "siparisAdı", "siparisNo", "birimFiyat", "faturaNo", siparisadet, tutar, siparisveren) FROM stdin;
\.


--
-- TOC entry 5020 (class 0 OID 16846)
-- Dependencies: 232
-- Data for Name: soforler; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.soforler ("calisanİd", "bolumİd", ad, soyad, gorevturu, maas, deneyim, aractipi, aracid, departman) FROM stdin;
\.


--
-- TOC entry 5016 (class 0 OID 16698)
-- Dependencies: 228
-- Data for Name: tedarikci; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tedarikci ("tedarikciİd", "ilceNo", "kategoriİd", "telefonNo", ad) FROM stdin;
\.


--
-- TOC entry 5010 (class 0 OID 16462)
-- Dependencies: 222
-- Data for Name: urun; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.urun (urunadi, stok, "kategoriİd", "birimFiyat", "urunKodu") FROM stdin;
kereviz	0	1	21	2
ceviz	100	1	20	1
\.


--
-- TOC entry 5019 (class 0 OID 16809)
-- Dependencies: 231
-- Data for Name: yakitTuketim; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."yakitTuketim" ("kayıtİd", "aracİd", tarih, gidilenmesafe, "tüketilenyakıt", "yakıtmaliyet", yakitfiyati) FROM stdin;
3	1	2024-12-16	12	12	240	20
\.


--
-- TOC entry 5035 (class 0 OID 0)
-- Dependencies: 235
-- Name: calisan_calisanİd_seq; Type: SEQUENCE SET; Schema: Calisan; Owner: postgres
--

SELECT pg_catalog.setval('"Calisan"."calisan_calisanİd_seq"', 3, true);


--
-- TOC entry 5036 (class 0 OID 0)
-- Dependencies: 236
-- Name: arac_aracİd_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."arac_aracİd_seq"', 1, false);


--
-- TOC entry 5037 (class 0 OID 0)
-- Dependencies: 237
-- Name: depo_depoİd_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."depo_depoİd_seq"', 1, false);


--
-- TOC entry 5038 (class 0 OID 0)
-- Dependencies: 238
-- Name: depobolum_bolumİd_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."depobolum_bolumİd_seq"', 1, false);


--
-- TOC entry 5039 (class 0 OID 0)
-- Dependencies: 239
-- Name: kategori_kategoriİd_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."kategori_kategoriİd_seq"', 1, false);


--
-- TOC entry 5040 (class 0 OID 0)
-- Dependencies: 240
-- Name: siparisurun_siparisNo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."siparisurun_siparisNo_seq"', 1, false);


--
-- TOC entry 5041 (class 0 OID 0)
-- Dependencies: 241
-- Name: tedarikci_tedarikciİd_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tedarikci_tedarikciİd_seq"', 1, false);


--
-- TOC entry 4832 (class 2606 OID 16739)
-- Name: calisan calisan_pk; Type: CONSTRAINT; Schema: Calisan; Owner: postgres
--

ALTER TABLE ONLY "Calisan".calisan
    ADD CONSTRAINT calisan_pk PRIMARY KEY ("calisanİd");


--
-- TOC entry 4834 (class 2606 OID 16748)
-- Name: calisan calisan_unique; Type: CONSTRAINT; Schema: Calisan; Owner: postgres
--

ALTER TABLE ONLY "Calisan".calisan
    ADD CONSTRAINT calisan_unique UNIQUE ("calisanİd");


--
-- TOC entry 4817 (class 2606 OID 16599)
-- Name: arac arac_aracTipi_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arac
    ADD CONSTRAINT "arac_aracTipi_key" UNIQUE ("aracTipi");


--
-- TOC entry 4819 (class 2606 OID 16597)
-- Name: arac arac_aracİd_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arac
    ADD CONSTRAINT "arac_aracİd_key" UNIQUE ("aracİd");


--
-- TOC entry 4821 (class 2606 OID 16595)
-- Name: arac arac_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arac
    ADD CONSTRAINT arac_pkey PRIMARY KEY ("aracİd");


--
-- TOC entry 4793 (class 2606 OID 16448)
-- Name: depo depo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depo
    ADD CONSTRAINT depo_pkey PRIMARY KEY ("depoİd");


--
-- TOC entry 4837 (class 2606 OID 16803)
-- Name: depobakım depobakım_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."depobakım"
    ADD CONSTRAINT "depobakım_pkey" PRIMARY KEY ("depoİd");


--
-- TOC entry 4811 (class 2606 OID 16539)
-- Name: depobolum depobolum_bolumİd_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depobolum
    ADD CONSTRAINT "depobolum_bolumİd_key" UNIQUE ("bolumİd");


--
-- TOC entry 4813 (class 2606 OID 16517)
-- Name: depobolum depobolum_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depobolum
    ADD CONSTRAINT depobolum_pkey PRIMARY KEY ("bolumİd", "depoİd", "kategoriİd");


--
-- TOC entry 4803 (class 2606 OID 16481)
-- Name: fatura fatura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fatura
    ADD CONSTRAINT fatura_pkey PRIMARY KEY ("faturaNo");


--
-- TOC entry 4788 (class 2606 OID 16427)
-- Name: il il_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.il
    ADD CONSTRAINT il_pkey PRIMARY KEY ("ilNo");


--
-- TOC entry 4791 (class 2606 OID 16434)
-- Name: ilce ilce_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilce
    ADD CONSTRAINT ilce_pkey PRIMARY KEY ("ilceNo");


--
-- TOC entry 4796 (class 2606 OID 16461)
-- Name: kategori kategori_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategori
    ADD CONSTRAINT kategori_pkey PRIMARY KEY ("kategoriİd");


--
-- TOC entry 4825 (class 2606 OID 16650)
-- Name: sevkiyat sevkiyat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sevkiyat
    ADD CONSTRAINT sevkiyat_pkey PRIMARY KEY ("siparisNo");


--
-- TOC entry 4807 (class 2606 OID 16489)
-- Name: siparisurun siparisurun_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisurun
    ADD CONSTRAINT siparisurun_pkey PRIMARY KEY ("siparisNo", "faturaNo", "urunKodu");


--
-- TOC entry 4809 (class 2606 OID 16643)
-- Name: siparisurun siparisurun_siparisNo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisurun
    ADD CONSTRAINT "siparisurun_siparisNo_key" UNIQUE ("siparisNo");


--
-- TOC entry 4828 (class 2606 OID 16705)
-- Name: tedarikci tedarikci_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tedarikci
    ADD CONSTRAINT tedarikci_pkey PRIMARY KEY ("tedarikciİd", "telefonNo");


--
-- TOC entry 4830 (class 2606 OID 16707)
-- Name: tedarikci tedarikci_tedarikciİd_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tedarikci
    ADD CONSTRAINT "tedarikci_tedarikciİd_key" UNIQUE ("tedarikciİd");


--
-- TOC entry 4799 (class 2606 OID 16499)
-- Name: urun urunKodu; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urun
    ADD CONSTRAINT "urunKodu" UNIQUE ("urunKodu");


--
-- TOC entry 4801 (class 2606 OID 16497)
-- Name: urun urun_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urun
    ADD CONSTRAINT urun_pkey PRIMARY KEY ("urunKodu");


--
-- TOC entry 4839 (class 2606 OID 16814)
-- Name: yakitTuketim yakıtTüketim_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."yakitTuketim"
    ADD CONSTRAINT "yakıtTüketim_pkey" PRIMARY KEY ("kayıtİd");


--
-- TOC entry 4835 (class 1259 OID 16746)
-- Name: fki_calisan_fk; Type: INDEX; Schema: Calisan; Owner: postgres
--

CREATE INDEX fki_calisan_fk ON "Calisan".calisan USING btree ("bolumİd");


--
-- TOC entry 4822 (class 1259 OID 16667)
-- Name: fki_aracsevkiyat_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_aracsevkiyat_fk ON public.sevkiyat USING btree ("aracİd");


--
-- TOC entry 4814 (class 1259 OID 16523)
-- Name: fki_bolumDepo_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_bolumDepo_fk" ON public.depobolum USING btree ("depoİd");


--
-- TOC entry 4823 (class 1259 OID 16661)
-- Name: fki_depoidsevkiyat_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_depoidsevkiyat_fk ON public.sevkiyat USING btree ("depoİd");


--
-- TOC entry 4794 (class 1259 OID 16454)
-- Name: fki_ilceno_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_ilceno_fk ON public.depo USING btree ("ilceNo");


--
-- TOC entry 4789 (class 1259 OID 16440)
-- Name: fki_ilno_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_ilno_fk ON public.ilce USING btree ("ilNo");


--
-- TOC entry 4815 (class 1259 OID 16529)
-- Name: fki_k; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_k ON public.depobolum USING btree ("kategoriİd");


--
-- TOC entry 4826 (class 1259 OID 16718)
-- Name: fki_kategoritedarik_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_kategoritedarik_fk ON public.tedarikci USING btree ("kategoriİd");


--
-- TOC entry 4804 (class 1259 OID 16495)
-- Name: fki_siparisurun_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_siparisurun_fk ON public.siparisurun USING btree ("faturaNo");


--
-- TOC entry 4805 (class 1259 OID 16887)
-- Name: fki_siparisveren; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_siparisveren ON public.siparisurun USING btree (siparisveren);


--
-- TOC entry 4797 (class 1259 OID 16476)
-- Name: fki_urunkategori_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_urunkategori_fk ON public.urun USING btree ("kategoriİd");


--
-- TOC entry 4858 (class 2620 OID 16843)
-- Name: calisan maas_kontrol_trigger; Type: TRIGGER; Schema: Calisan; Owner: postgres
--

CREATE TRIGGER maas_kontrol_trigger BEFORE INSERT OR UPDATE OF maas ON "Calisan".calisan FOR EACH ROW EXECUTE FUNCTION "Calisan".maas_kontrol();


--
-- TOC entry 4859 (class 2620 OID 16873)
-- Name: calisan trigger_calisanlar_insert; Type: TRIGGER; Schema: Calisan; Owner: postgres
--

CREATE TRIGGER trigger_calisanlar_insert BEFORE INSERT OR UPDATE ON "Calisan".calisan FOR EACH ROW EXECUTE FUNCTION "Calisan".calisanlar_insert_trigger();


--
-- TOC entry 4860 (class 2620 OID 16838)
-- Name: yakitTuketim maliyethesabi; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER maliyethesabi BEFORE INSERT ON public."yakitTuketim" FOR EACH ROW EXECUTE FUNCTION public.yakitmaliyethesabi();


--
-- TOC entry 4856 (class 2620 OID 16835)
-- Name: siparisurun sevkiyattutar; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER sevkiyattutar BEFORE INSERT ON public.siparisurun FOR EACH ROW EXECUTE FUNCTION public.siparistoplamtutar();


--
-- TOC entry 4857 (class 2620 OID 16830)
-- Name: siparisurun siparis; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER siparis AFTER INSERT ON public.siparisurun FOR EACH ROW EXECUTE FUNCTION public.siparisurunarttir();


--
-- TOC entry 4853 (class 2606 OID 16741)
-- Name: calisan calisan_fk; Type: FK CONSTRAINT; Schema: Calisan; Owner: postgres
--

ALTER TABLE ONLY "Calisan".calisan
    ADD CONSTRAINT calisan_fk FOREIGN KEY ("bolumİd") REFERENCES public.depobolum("bolumİd") NOT VALID;


--
-- TOC entry 4848 (class 2606 OID 16662)
-- Name: sevkiyat aracsevkiyat_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sevkiyat
    ADD CONSTRAINT aracsevkiyat_fk FOREIGN KEY ("aracİd") REFERENCES public.arac("aracİd") NOT VALID;


--
-- TOC entry 4846 (class 2606 OID 16518)
-- Name: depobolum bolumDepo_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depobolum
    ADD CONSTRAINT "bolumDepo_fk" FOREIGN KEY ("depoİd") REFERENCES public.depo("depoİd") NOT VALID;


--
-- TOC entry 4847 (class 2606 OID 16524)
-- Name: depobolum bolumKategori_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depobolum
    ADD CONSTRAINT "bolumKategori_fk" FOREIGN KEY ("kategoriİd") REFERENCES public.kategori("kategoriİd") NOT VALID;


--
-- TOC entry 4854 (class 2606 OID 16804)
-- Name: depobakım depobakım_depoİd_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."depobakım"
    ADD CONSTRAINT "depobakım_depoİd_fkey" FOREIGN KEY ("depoİd") REFERENCES public.depo("depoİd");


--
-- TOC entry 4849 (class 2606 OID 16656)
-- Name: sevkiyat depoidsevkiyat_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sevkiyat
    ADD CONSTRAINT depoidsevkiyat_fk FOREIGN KEY ("depoİd") REFERENCES public.depo("depoİd") NOT VALID;


--
-- TOC entry 4841 (class 2606 OID 16449)
-- Name: depo ilceno_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depo
    ADD CONSTRAINT ilceno_fk FOREIGN KEY ("ilceNo") REFERENCES public.ilce("ilceNo") NOT VALID;


--
-- TOC entry 4840 (class 2606 OID 16435)
-- Name: ilce ilno_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilce
    ADD CONSTRAINT ilno_fk FOREIGN KEY ("ilNo") REFERENCES public.il("ilNo") NOT VALID;


--
-- TOC entry 4851 (class 2606 OID 16713)
-- Name: tedarikci kategoritedarik_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tedarikci
    ADD CONSTRAINT kategoritedarik_fk FOREIGN KEY ("kategoriİd") REFERENCES public.kategori("kategoriİd") NOT VALID;


--
-- TOC entry 4850 (class 2606 OID 16651)
-- Name: sevkiyat sevkiyat_siparisNo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sevkiyat
    ADD CONSTRAINT "sevkiyat_siparisNo_fkey" FOREIGN KEY ("siparisNo") REFERENCES public.siparisurun("siparisNo");


--
-- TOC entry 4843 (class 2606 OID 16500)
-- Name: siparisurun siparisfatura_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisurun
    ADD CONSTRAINT siparisfatura_fk FOREIGN KEY ("faturaNo") REFERENCES public.fatura("faturaNo") NOT VALID;


--
-- TOC entry 4844 (class 2606 OID 16505)
-- Name: siparisurun siparisurun_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisurun
    ADD CONSTRAINT siparisurun_fk FOREIGN KEY ("urunKodu") REFERENCES public.urun("urunKodu") NOT VALID;


--
-- TOC entry 4845 (class 2606 OID 16882)
-- Name: siparisurun siparisveren; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisurun
    ADD CONSTRAINT siparisveren FOREIGN KEY (siparisveren) REFERENCES "Calisan".calisan("calisanİd") NOT VALID;


--
-- TOC entry 4852 (class 2606 OID 16708)
-- Name: tedarikci tedarikci_ilceNo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tedarikci
    ADD CONSTRAINT "tedarikci_ilceNo_fkey" FOREIGN KEY ("ilceNo") REFERENCES public.ilce("ilceNo");


--
-- TOC entry 4842 (class 2606 OID 16471)
-- Name: urun urunkategori_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urun
    ADD CONSTRAINT urunkategori_fk FOREIGN KEY ("kategoriİd") REFERENCES public.kategori("kategoriİd") NOT VALID;


--
-- TOC entry 4855 (class 2606 OID 16815)
-- Name: yakitTuketim yakıtTüketim_aracİd_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."yakitTuketim"
    ADD CONSTRAINT "yakıtTüketim_aracİd_fkey" FOREIGN KEY ("aracİd") REFERENCES public.arac("aracİd");


-- Completed on 2024-12-21 18:19:38

--
-- PostgreSQL database dump complete
--

