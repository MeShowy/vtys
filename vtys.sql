--
-- PostgreSQL database dump
--

-- Dumped from database version 15.10
-- Dumped by pg_dump version 15.10

-- Started on 2024-12-24 09:22:17

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 16407)
-- Name: calisan; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA calisan;


ALTER SCHEMA calisan OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 16384)
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- TOC entry 267 (class 1255 OID 16664)
-- Name: calisanlar_insert_trigger(); Type: FUNCTION; Schema: calisan; Owner: postgres
--

CREATE FUNCTION calisan.calisanlar_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    -- Eğer veri ebeveyn tablodaysa ve ilgili çocuk tabloya eklenmesi gerekiyorsa
    IF TG_TABLE_NAME = 'calisan' THEN
        -- Eğer gorevTuru 'Şoför' ise, sofor tablosuna ekle
	    IF NEW.gorev_turu = 'sofor' THEN
	        INSERT INTO soforler (calisan_id, bolum_id, ad, soyad, gorev_turu, maas,departman ,deneyim, arac_tipi, arac_id)
	        VALUES (NEW.calisan_id, NEW.bolum_id, NEW.ad, NEW.soyad, NEW.gorev_turu, NEW.maas, new.departman, NEW.deneyim, new.arac_tipi, new.arac_id);
	
	    -- Eğer gorevTuru 'Müdür' ise, mudurler tablosuna ekleme yap
	    ELSIF NEW.gorev_turu = 'mudur' THEN
	        INSERT INTO mudurler (calisan_id, bolum_id, ad, soyad, gorev_turu, maas,departman ,deneyim, arac_tipi, arac_id)
	        VALUES (NEW.calisan_id, NEW.bolum_id, NEW.ad, NEW.soyad, NEW.gorev_turu, NEW.maas, new.departman, NEW.deneyim, null, null);
	
	    -- Eğer gorevTuru 'Depo Çalışanı' ise, depocalisanlar tablosuna ekleme yap
	    ELSIF NEW.gorev_turu = 'depocalisan' THEN
	        INSERT INTO depocalisanlar (calisan_id, bolum_id, ad, soyad, gorev_turu, maas,departman ,deneyim, arac_tipi, arac_id)
	        VALUES (NEW.calisan_id, NEW.bolum_id, NEW.ad, NEW.soyad, NEW.gorev_turu, NEW.maas, NEW.departman, NEW.deneyim,null,null);

        END IF;
    END IF;

    -- NEW kaydını geri döndür
    RETURN null;
END;

$$;


ALTER FUNCTION calisan.calisanlar_insert_trigger() OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 16665)
-- Name: maas_kontrol(); Type: FUNCTION; Schema: calisan; Owner: postgres
--

CREATE FUNCTION calisan.maas_kontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    IF NEW.maas < 5000 THEN
        RAISE EXCEPTION 'Maas 5000 TL''den kucuk olamaz';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION calisan.maas_kontrol() OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 16774)
-- Name: arac_maliyet_silme(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.arac_maliyet_silme() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM "yakit_tuketim"
    WHERE "arac_id" = OLD."arac_id";


    RETURN old;
END;
$$;


ALTER FUNCTION public.arac_maliyet_silme() OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 16666)
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
    WHERE "siparis_no" = siparisno;

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
-- TOC entry 262 (class 1255 OID 16667)
-- Name: siparisler_sira(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparisler_sira(siparis_veren_no integer) RETURNS TABLE(urunadi text, fiyat integer)
    LANGUAGE plpgsql
    AS $$
begin
	return query select "siparis_adi","tutar" from "siparisurun" 
	where "siparis_veren" = siparis_veren_no order by  "tutar" desc;
end;
$$;


ALTER FUNCTION public.siparisler_sira(siparis_veren_no integer) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 16668)
-- Name: siparistoplamtutar(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparistoplamtutar() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	NEW."tutar" := NEW."birim_fiyat" * NEW."siparis_adet";
	return new;
end;
$$;


ALTER FUNCTION public.siparistoplamtutar() OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 16776)
-- Name: siparisurun_silme_fonksiyonu(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparisurun_silme_fonksiyonu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    

    -- SEVKIYAT tablosundan silinen SIPARISURUN.SIPARISNO ile eşleşen kayıtları sil
    DELETE FROM "sevkiyat"
    WHERE "siparis_no" = OLD."siparis_no";

    RETURN old; -- After DELETE trigger'da dönüş yapmaya gerek yok.
END;
$$;


ALTER FUNCTION public.siparisurun_silme_fonksiyonu() OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 16669)
-- Name: siparisurunarttir(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparisurunarttir() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	declare
		s_adet integer;
begin
s_adet:= (select siparis_adet from siparisurun order by "siparis_no" desc limit 1);
update urun set stok = stok+s_adet;
return new;
end;
$$;


ALTER FUNCTION public.siparisurunarttir() OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 16670)
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
    WHERE "urun_kodu" = urun_kod;

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
-- TOC entry 266 (class 1255 OID 16671)
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
    WHERE "urun_kodu" = urun_kod;

    IF mevcut_stok IS NULL THEN
        RETURN 'Ürün bulunamadı';
    ELSIF mevcut_stok < miktar THEN
        RETURN 'Yetersiz stok';
    ELSE
        UPDATE "urun"
        SET "stok" = "stok" - miktar
        WHERE "urun_kodu" = urun_kod;

        RETURN 'Stok güncellendi. Kalan stok: ' || (mevcut_stok - miktar);
    END IF;
END;
$$;


ALTER FUNCTION public.stoktan_urun_cikar(urun_kod integer, miktar integer) OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 16759)
-- Name: yakit_maliyet_hesapla(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.yakit_maliyet_hesapla() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    
    NEW."yakit_maliyet" := NEW."yakit_fiyati" * NEW."tuketilen_yakit";
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.yakit_maliyet_hesapla() OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 16758)
-- Name: yakitmaliyethesabi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.yakitmaliyethesabi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	begin
	NEW."yakit_maliyet" := NEW."yakit_fiyati" * NEW."tuketilen_yakit" ;
	return new;
end;
$$;


ALTER FUNCTION public.yakitmaliyethesabi() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 16504)
-- Name: calisan; Type: TABLE; Schema: calisan; Owner: postgres
--

CREATE TABLE calisan.calisan (
    calisan_id integer NOT NULL,
    bolum_id integer NOT NULL,
    ad text NOT NULL,
    soyad text NOT NULL,
    gorev_turu text,
    maas integer,
    departman character varying(100),
    deneyim integer,
    arac_id integer,
    arac_tipi text,
    CONSTRAINT check_gorevturu CHECK ((gorev_turu = ANY (ARRAY['sofor'::text, 'mudur'::text, 'depocalisan'::text])))
);


ALTER TABLE calisan.calisan OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16503)
-- Name: calisan_calisan_id_seq; Type: SEQUENCE; Schema: calisan; Owner: postgres
--

CREATE SEQUENCE calisan.calisan_calisan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE calisan.calisan_calisan_id_seq OWNER TO postgres;

--
-- TOC entry 3531 (class 0 OID 0)
-- Dependencies: 216
-- Name: calisan_calisan_id_seq; Type: SEQUENCE OWNED BY; Schema: calisan; Owner: postgres
--

ALTER SEQUENCE calisan.calisan_calisan_id_seq OWNED BY calisan.calisan.calisan_id;


--
-- TOC entry 219 (class 1259 OID 16514)
-- Name: arac; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.arac (
    arac_id integer NOT NULL,
    arac_tipi text NOT NULL
);


ALTER TABLE public.arac OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16513)
-- Name: arac_arac_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.arac_arac_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.arac_arac_id_seq OWNER TO postgres;

--
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 218
-- Name: arac_arac_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.arac_arac_id_seq OWNED BY public.arac.arac_id;


--
-- TOC entry 221 (class 1259 OID 16523)
-- Name: depo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.depo (
    depo_id integer NOT NULL,
    ilce_no integer NOT NULL,
    depo_adi text,
    kapasite integer DEFAULT 0
);


ALTER TABLE public.depo OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16522)
-- Name: depo_depo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.depo_depo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.depo_depo_id_seq OWNER TO postgres;

--
-- TOC entry 3533 (class 0 OID 0)
-- Dependencies: 220
-- Name: depo_depo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.depo_depo_id_seq OWNED BY public.depo.depo_id;


--
-- TOC entry 222 (class 1259 OID 16532)
-- Name: depobakım; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."depobakım" (
    depo_id integer NOT NULL,
    bakim_maliyet integer NOT NULL,
    bakim_tur text NOT NULL,
    bakim_tarih date NOT NULL
);


ALTER TABLE public."depobakım" OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16538)
-- Name: depobolum; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.depobolum (
    bolum_id integer NOT NULL,
    depo_id integer NOT NULL,
    kategori_id integer NOT NULL,
    kapasite integer DEFAULT 0,
    bolum_adi text
);


ALTER TABLE public.depobolum OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16537)
-- Name: depobolum_bolum_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.depobolum_bolum_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.depobolum_bolum_id_seq OWNER TO postgres;

--
-- TOC entry 3534 (class 0 OID 0)
-- Dependencies: 223
-- Name: depobolum_bolum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.depobolum_bolum_id_seq OWNED BY public.depobolum.bolum_id;


--
-- TOC entry 225 (class 1259 OID 16547)
-- Name: depocalisanlar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.depocalisanlar (
    departman character varying(100),
    deneyim integer
)
INHERITS (calisan.calisan);


ALTER TABLE public.depocalisanlar OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16555)
-- Name: fatura; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fatura (
    fatura_no integer NOT NULL,
    fatura_tarihi date
);


ALTER TABLE public.fatura OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16554)
-- Name: fatura_fatura_no_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fatura_fatura_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fatura_fatura_no_seq OWNER TO postgres;

--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 226
-- Name: fatura_fatura_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fatura_fatura_no_seq OWNED BY public.fatura.fatura_no;


--
-- TOC entry 229 (class 1259 OID 16562)
-- Name: il; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.il (
    il_adi text NOT NULL,
    il_no integer NOT NULL
);


ALTER TABLE public.il OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16561)
-- Name: il_il_no_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.il_il_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.il_il_no_seq OWNER TO postgres;

--
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 228
-- Name: il_il_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.il_il_no_seq OWNED BY public.il.il_no;


--
-- TOC entry 231 (class 1259 OID 16571)
-- Name: ilce; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ilce (
    ilce_adi text NOT NULL,
    ilce_no integer NOT NULL,
    il_no integer NOT NULL
);


ALTER TABLE public.ilce OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16570)
-- Name: ilce_ilce_no_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ilce_ilce_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ilce_ilce_no_seq OWNER TO postgres;

--
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 230
-- Name: ilce_ilce_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ilce_ilce_no_seq OWNED BY public.ilce.ilce_no;


--
-- TOC entry 233 (class 1259 OID 16580)
-- Name: kategori; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kategori (
    kategori_id integer NOT NULL,
    kategori_adi text NOT NULL
);


ALTER TABLE public.kategori OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16579)
-- Name: kategori_kategori_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kategori_kategori_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kategori_kategori_id_seq OWNER TO postgres;

--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 232
-- Name: kategori_kategori_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kategori_kategori_id_seq OWNED BY public.kategori.kategori_id;


--
-- TOC entry 234 (class 1259 OID 16588)
-- Name: mudurler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mudurler (
    departman character varying(100),
    deneyim integer
)
INHERITS (calisan.calisan);


ALTER TABLE public.mudurler OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16595)
-- Name: sevkiyat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sevkiyat (
    siparis_no integer NOT NULL,
    depo_id integer NOT NULL,
    arac_id integer NOT NULL,
    tarih date NOT NULL
);


ALTER TABLE public.sevkiyat OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16599)
-- Name: siparisurun; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.siparisurun (
    urun_kodu integer NOT NULL,
    siparis_adi text,
    siparis_no integer NOT NULL,
    birim_fiyat integer DEFAULT 0,
    fatura_no integer NOT NULL,
    siparis_adet integer,
    tutar integer,
    siparis_veren integer
);


ALTER TABLE public.siparisurun OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16598)
-- Name: siparisurun_siparis_no_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.siparisurun_siparis_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.siparisurun_siparis_no_seq OWNER TO postgres;

--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 236
-- Name: siparisurun_siparis_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.siparisurun_siparis_no_seq OWNED BY public.siparisurun.siparis_no;


--
-- TOC entry 238 (class 1259 OID 16608)
-- Name: soforler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.soforler (
    deneyim integer,
    aractipi text,
    aracid integer
)
INHERITS (calisan.calisan);


ALTER TABLE public.soforler OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 16616)
-- Name: tedarikci; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tedarikci (
    tedarikci_id integer NOT NULL,
    ilce_no integer NOT NULL,
    kategori_id integer NOT NULL,
    telefon_no "char" NOT NULL,
    ad text,
    CONSTRAINT "tedarikci.telefon_no = 10" CHECK (true)
);


ALTER TABLE public.tedarikci OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16615)
-- Name: tedarikci_tedarikci_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tedarikci_tedarikci_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tedarikci_tedarikci_id_seq OWNER TO postgres;

--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 239
-- Name: tedarikci_tedarikci_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tedarikci_tedarikci_id_seq OWNED BY public.tedarikci.tedarikci_id;


--
-- TOC entry 242 (class 1259 OID 16626)
-- Name: urun; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.urun (
    urun_adi text NOT NULL,
    stok integer DEFAULT 0,
    kategori_id integer NOT NULL,
    birim_fiyat integer DEFAULT 0,
    urun_kodu integer NOT NULL
);


ALTER TABLE public.urun OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 16625)
-- Name: urun_urun_kodu_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.urun_urun_kodu_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.urun_urun_kodu_seq OWNER TO postgres;

--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 241
-- Name: urun_urun_kodu_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.urun_urun_kodu_seq OWNED BY public.urun.urun_kodu;


--
-- TOC entry 244 (class 1259 OID 16637)
-- Name: yakit_tuketim; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.yakit_tuketim (
    kayit_id integer NOT NULL,
    arac_id integer NOT NULL,
    tarih date NOT NULL,
    gidilen_mesafe integer,
    tuketilen_yakit integer,
    yakit_maliyet integer DEFAULT 40,
    yakit_fiyati integer DEFAULT 20
);


ALTER TABLE public.yakit_tuketim OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16636)
-- Name: yakitTuketim_kayıt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."yakitTuketim_kayıt_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."yakitTuketim_kayıt_id_seq" OWNER TO postgres;

--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 243
-- Name: yakitTuketim_kayıt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."yakitTuketim_kayıt_id_seq" OWNED BY public.yakit_tuketim.kayit_id;


--
-- TOC entry 3262 (class 2604 OID 16507)
-- Name: calisan calisan_id; Type: DEFAULT; Schema: calisan; Owner: postgres
--

ALTER TABLE ONLY calisan.calisan ALTER COLUMN calisan_id SET DEFAULT nextval('calisan.calisan_calisan_id_seq'::regclass);


--
-- TOC entry 3263 (class 2604 OID 16517)
-- Name: arac arac_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arac ALTER COLUMN arac_id SET DEFAULT nextval('public.arac_arac_id_seq'::regclass);


--
-- TOC entry 3264 (class 2604 OID 16526)
-- Name: depo depo_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depo ALTER COLUMN depo_id SET DEFAULT nextval('public.depo_depo_id_seq'::regclass);


--
-- TOC entry 3266 (class 2604 OID 16541)
-- Name: depobolum bolum_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depobolum ALTER COLUMN bolum_id SET DEFAULT nextval('public.depobolum_bolum_id_seq'::regclass);


--
-- TOC entry 3268 (class 2604 OID 16550)
-- Name: depocalisanlar calisan_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depocalisanlar ALTER COLUMN calisan_id SET DEFAULT nextval('calisan.calisan_calisan_id_seq'::regclass);


--
-- TOC entry 3269 (class 2604 OID 16558)
-- Name: fatura fatura_no; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fatura ALTER COLUMN fatura_no SET DEFAULT nextval('public.fatura_fatura_no_seq'::regclass);


--
-- TOC entry 3270 (class 2604 OID 16565)
-- Name: il il_no; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.il ALTER COLUMN il_no SET DEFAULT nextval('public.il_il_no_seq'::regclass);


--
-- TOC entry 3271 (class 2604 OID 16574)
-- Name: ilce ilce_no; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilce ALTER COLUMN ilce_no SET DEFAULT nextval('public.ilce_ilce_no_seq'::regclass);


--
-- TOC entry 3272 (class 2604 OID 16583)
-- Name: kategori kategori_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategori ALTER COLUMN kategori_id SET DEFAULT nextval('public.kategori_kategori_id_seq'::regclass);


--
-- TOC entry 3273 (class 2604 OID 16591)
-- Name: mudurler calisan_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mudurler ALTER COLUMN calisan_id SET DEFAULT nextval('calisan.calisan_calisan_id_seq'::regclass);


--
-- TOC entry 3274 (class 2604 OID 16602)
-- Name: siparisurun siparis_no; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisurun ALTER COLUMN siparis_no SET DEFAULT nextval('public.siparisurun_siparis_no_seq'::regclass);


--
-- TOC entry 3276 (class 2604 OID 16611)
-- Name: soforler calisan_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soforler ALTER COLUMN calisan_id SET DEFAULT nextval('calisan.calisan_calisan_id_seq'::regclass);


--
-- TOC entry 3277 (class 2604 OID 16619)
-- Name: tedarikci tedarikci_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tedarikci ALTER COLUMN tedarikci_id SET DEFAULT nextval('public.tedarikci_tedarikci_id_seq'::regclass);


--
-- TOC entry 3280 (class 2604 OID 16631)
-- Name: urun urun_kodu; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urun ALTER COLUMN urun_kodu SET DEFAULT nextval('public.urun_urun_kodu_seq'::regclass);


--
-- TOC entry 3281 (class 2604 OID 16640)
-- Name: yakit_tuketim kayit_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yakit_tuketim ALTER COLUMN kayit_id SET DEFAULT nextval('public."yakitTuketim_kayıt_id_seq"'::regclass);


--
-- TOC entry 3497 (class 0 OID 16504)
-- Dependencies: 217
-- Data for Name: calisan; Type: TABLE DATA; Schema: calisan; Owner: postgres
--

COPY calisan.calisan (calisan_id, bolum_id, ad, soyad, gorev_turu, maas, departman, deneyim, arac_id, arac_tipi) FROM stdin;
\.


--
-- TOC entry 3499 (class 0 OID 16514)
-- Dependencies: 219
-- Data for Name: arac; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.arac (arac_id, arac_tipi) FROM stdin;
1	Transit
3	Tır
4	Teslim Aracı
6	Kamyonet
8	denemeUpdate
7	denemeUpdate
9	denemeUpdate
\.


--
-- TOC entry 3501 (class 0 OID 16523)
-- Dependencies: 221
-- Data for Name: depo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.depo (depo_id, ilce_no, depo_adi, kapasite) FROM stdin;
2	1	Yeni Merkez Depo	6000
3	2	Yeni Merkez Depo	6000
4	2	Yeni Merkez Depo	6000
5	2	Merkez Depo	6000
\.


--
-- TOC entry 3502 (class 0 OID 16532)
-- Dependencies: 222
-- Data for Name: depobakım; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."depobakım" (depo_id, bakim_maliyet, bakim_tur, bakim_tarih) FROM stdin;
2	2500	Yıllık Bakım	2024-12-22
\.


--
-- TOC entry 3504 (class 0 OID 16538)
-- Dependencies: 224
-- Data for Name: depobolum; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.depobolum (bolum_id, depo_id, kategori_id, kapasite, bolum_adi) FROM stdin;
3	2	3	100	Soğuk Depo
5	2	3	100	Depo
4	2	3	100	İyi Depo
\.


--
-- TOC entry 3505 (class 0 OID 16547)
-- Dependencies: 225
-- Data for Name: depocalisanlar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.depocalisanlar (calisan_id, bolum_id, ad, soyad, gorev_turu, maas, departman, deneyim, arac_id, arac_tipi) FROM stdin;
14	3	ozan	Yılmaz	depocalisan	10000	Teknik	5	\N	\N
\.


--
-- TOC entry 3507 (class 0 OID 16555)
-- Dependencies: 227
-- Data for Name: fatura; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fatura (fatura_no, fatura_tarihi) FROM stdin;
1	2024-12-23
2	2024-12-23
3	2024-12-23
4	2024-12-23
5	2024-12-23
6	2024-12-23
7	2024-12-23
8	2024-12-23
9	2024-12-23
10	2024-12-23
11	2024-12-23
12	2024-12-23
13	2024-12-23
\.


--
-- TOC entry 3509 (class 0 OID 16562)
-- Dependencies: 229
-- Data for Name: il; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.il (il_adi, il_no) FROM stdin;
sakarya	1
izmir	2
ankara	3
istanbul	4
\.


--
-- TOC entry 3511 (class 0 OID 16571)
-- Dependencies: 231
-- Data for Name: ilce; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ilce (ilce_adi, ilce_no, il_no) FROM stdin;
serdivan	1	1
kadikoy	2	4
cankaya	3	3
karsiyaka	4	2
\.


--
-- TOC entry 3513 (class 0 OID 16580)
-- Dependencies: 233
-- Data for Name: kategori; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kategori (kategori_id, kategori_adi) FROM stdin;
1	Elektronik
2	Gıda
3	Gümrük
4	Giyim
5	Bahçe
\.


--
-- TOC entry 3514 (class 0 OID 16588)
-- Dependencies: 234
-- Data for Name: mudurler; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mudurler (calisan_id, bolum_id, ad, soyad, gorev_turu, maas, departman, deneyim, arac_id, arac_tipi) FROM stdin;
8	3	atakan	Yılmaz	mudur	10000	Teknik	5	\N	\N
\.


--
-- TOC entry 3515 (class 0 OID 16595)
-- Dependencies: 235
-- Data for Name: sevkiyat; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sevkiyat (siparis_no, depo_id, arac_id, tarih) FROM stdin;
13	2	3	2024-12-25
\.


--
-- TOC entry 3517 (class 0 OID 16599)
-- Dependencies: 237
-- Data for Name: siparisurun; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.siparisurun (urun_kodu, siparis_adi, siparis_no, birim_fiyat, fatura_no, siparis_adet, tutar, siparis_veren) FROM stdin;
2	Telefon	11	15000	1	2	30000	14
2	Telefon	13	15000	12	2	30000	14
2	Telefon	14	15000	13	2	30000	14
\.


--
-- TOC entry 3518 (class 0 OID 16608)
-- Dependencies: 238
-- Data for Name: soforler; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.soforler (calisan_id, bolum_id, ad, soyad, gorev_turu, maas, departman, deneyim, arac_id, arac_tipi, aractipi, aracid) FROM stdin;
10	3	atakan	Yılmaz	sofor	10000	Teknik	5	3	\N	\N	\N
\.


--
-- TOC entry 3520 (class 0 OID 16616)
-- Dependencies: 240
-- Data for Name: tedarikci; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tedarikci (tedarikci_id, ilce_no, kategori_id, telefon_no, ad) FROM stdin;
1	2	1	5	Brad
2	3	4	1	kero
3	3	3	2	fati
4	4	1	2	furki
\.


--
-- TOC entry 3522 (class 0 OID 16626)
-- Dependencies: 242
-- Data for Name: urun; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.urun (urun_adi, stok, kategori_id, birim_fiyat, urun_kodu) FROM stdin;
Telefon	50	2	15000	2
Laptop	50	2	15000	3
Tencere	48	2	15000	1
\.


--
-- TOC entry 3524 (class 0 OID 16637)
-- Dependencies: 244
-- Data for Name: yakit_tuketim; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.yakit_tuketim (kayit_id, arac_id, tarih, gidilen_mesafe, tuketilen_yakit, yakit_maliyet, yakit_fiyati) FROM stdin;
5	1	2024-12-23	100	10	200	20
4	1	2024-12-23	100	10	200	20
\.


--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 216
-- Name: calisan_calisan_id_seq; Type: SEQUENCE SET; Schema: calisan; Owner: postgres
--

SELECT pg_catalog.setval('calisan.calisan_calisan_id_seq', 14, true);


--
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 218
-- Name: arac_arac_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.arac_arac_id_seq', 9, true);


--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 220
-- Name: depo_depo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.depo_depo_id_seq', 5, true);


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 223
-- Name: depobolum_bolum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.depobolum_bolum_id_seq', 5, true);


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 226
-- Name: fatura_fatura_no_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fatura_fatura_no_seq', 13, true);


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 228
-- Name: il_il_no_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.il_il_no_seq', 4, true);


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 230
-- Name: ilce_ilce_no_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ilce_ilce_no_seq', 4, true);


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 232
-- Name: kategori_kategori_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kategori_kategori_id_seq', 5, true);


--
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 236
-- Name: siparisurun_siparis_no_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.siparisurun_siparis_no_seq', 14, true);


--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 239
-- Name: tedarikci_tedarikci_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tedarikci_tedarikci_id_seq', 4, true);


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 241
-- Name: urun_urun_kodu_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.urun_urun_kodu_seq', 3, true);


--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 243
-- Name: yakitTuketim_kayıt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."yakitTuketim_kayıt_id_seq"', 9, true);


--
-- TOC entry 3290 (class 2606 OID 16512)
-- Name: calisan calisan_pkey; Type: CONSTRAINT; Schema: calisan; Owner: postgres
--

ALTER TABLE ONLY calisan.calisan
    ADD CONSTRAINT calisan_pkey PRIMARY KEY (calisan_id);


--
-- TOC entry 3292 (class 2606 OID 16647)
-- Name: calisan calisan_unique; Type: CONSTRAINT; Schema: calisan; Owner: postgres
--

ALTER TABLE ONLY calisan.calisan
    ADD CONSTRAINT calisan_unique UNIQUE (calisan_id);


--
-- TOC entry 3295 (class 2606 OID 16649)
-- Name: arac arac_aracİd_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arac
    ADD CONSTRAINT "arac_aracİd_key" UNIQUE (arac_id);


--
-- TOC entry 3297 (class 2606 OID 16521)
-- Name: arac arac_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arac
    ADD CONSTRAINT arac_pkey PRIMARY KEY (arac_id);


--
-- TOC entry 3299 (class 2606 OID 16531)
-- Name: depo depo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depo
    ADD CONSTRAINT depo_pkey PRIMARY KEY (depo_id);


--
-- TOC entry 3302 (class 2606 OID 16546)
-- Name: depobolum depobolum_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depobolum
    ADD CONSTRAINT depobolum_pkey PRIMARY KEY (bolum_id);


--
-- TOC entry 3306 (class 2606 OID 16768)
-- Name: depocalisanlar depocalisanlar_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depocalisanlar
    ADD CONSTRAINT depocalisanlar_pk PRIMARY KEY (calisan_id);


--
-- TOC entry 3308 (class 2606 OID 16560)
-- Name: fatura fatura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fatura
    ADD CONSTRAINT fatura_pkey PRIMARY KEY (fatura_no);


--
-- TOC entry 3310 (class 2606 OID 16569)
-- Name: il il_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.il
    ADD CONSTRAINT il_pkey PRIMARY KEY (il_no);


--
-- TOC entry 3313 (class 2606 OID 16578)
-- Name: ilce ilce_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilce
    ADD CONSTRAINT ilce_pkey PRIMARY KEY (ilce_no);


--
-- TOC entry 3315 (class 2606 OID 16587)
-- Name: kategori kategori_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategori
    ADD CONSTRAINT kategori_pkey PRIMARY KEY (kategori_id);


--
-- TOC entry 3321 (class 2606 OID 16607)
-- Name: siparisurun siparis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisurun
    ADD CONSTRAINT siparis_pkey PRIMARY KEY (siparis_no);


--
-- TOC entry 3324 (class 2606 OID 16624)
-- Name: tedarikci tedarikci_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tedarikci
    ADD CONSTRAINT tedarikci_pkey PRIMARY KEY (tedarikci_id);


--
-- TOC entry 3327 (class 2606 OID 16635)
-- Name: urun urun_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urun
    ADD CONSTRAINT urun_pkey PRIMARY KEY (urun_kodu);


--
-- TOC entry 3329 (class 2606 OID 16644)
-- Name: yakit_tuketim yakittuketim_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yakit_tuketim
    ADD CONSTRAINT yakittuketim_pkey PRIMARY KEY (kayit_id);


--
-- TOC entry 3293 (class 1259 OID 16653)
-- Name: fki_calisan_fk; Type: INDEX; Schema: calisan; Owner: postgres
--

CREATE INDEX fki_calisan_fk ON calisan.calisan USING btree (bolum_id);


--
-- TOC entry 3316 (class 1259 OID 16654)
-- Name: fki_aracsevkiyat_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_aracsevkiyat_fk ON public.sevkiyat USING btree (arac_id);


--
-- TOC entry 3303 (class 1259 OID 16655)
-- Name: fki_bolumDepo_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_bolumDepo_fk" ON public.depobolum USING btree (depo_id);


--
-- TOC entry 3317 (class 1259 OID 16656)
-- Name: fki_depoidsevkiyat_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_depoidsevkiyat_fk ON public.sevkiyat USING btree (depo_id);


--
-- TOC entry 3300 (class 1259 OID 16657)
-- Name: fki_ilceno_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_ilceno_fk ON public.depo USING btree (ilce_no);


--
-- TOC entry 3311 (class 1259 OID 16658)
-- Name: fki_ilno_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_ilno_fk ON public.ilce USING btree (il_no);


--
-- TOC entry 3304 (class 1259 OID 16659)
-- Name: fki_k; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_k ON public.depobolum USING btree (kategori_id);


--
-- TOC entry 3322 (class 1259 OID 16660)
-- Name: fki_kategoritedarik_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_kategoritedarik_fk ON public.tedarikci USING btree (kategori_id);


--
-- TOC entry 3318 (class 1259 OID 16661)
-- Name: fki_siparisurun_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_siparisurun_fk ON public.siparisurun USING btree (fatura_no);


--
-- TOC entry 3319 (class 1259 OID 16662)
-- Name: fki_siparisveren; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_siparisveren ON public.siparisurun USING btree (siparis_veren);


--
-- TOC entry 3325 (class 1259 OID 16663)
-- Name: fki_urunkategori_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_urunkategori_fk ON public.urun USING btree (kategori_id);


--
-- TOC entry 3346 (class 2620 OID 16673)
-- Name: calisan maas_kontrol_trigger; Type: TRIGGER; Schema: calisan; Owner: postgres
--

CREATE TRIGGER maas_kontrol_trigger BEFORE INSERT OR UPDATE OF maas ON calisan.calisan FOR EACH ROW EXECUTE FUNCTION calisan.maas_kontrol();


--
-- TOC entry 3347 (class 2620 OID 16674)
-- Name: calisan trigger_calisanlar_insert; Type: TRIGGER; Schema: calisan; Owner: postgres
--

CREATE TRIGGER trigger_calisanlar_insert BEFORE INSERT OR UPDATE ON calisan.calisan FOR EACH ROW EXECUTE FUNCTION calisan.calisanlar_insert_trigger();


--
-- TOC entry 3348 (class 2620 OID 16775)
-- Name: arac arac_maliyet_silme_tr; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER arac_maliyet_silme_tr BEFORE DELETE ON public.arac FOR EACH ROW EXECUTE FUNCTION public.arac_maliyet_silme();


--
-- TOC entry 3349 (class 2620 OID 16676)
-- Name: siparisurun sevkiyattutar; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER sevkiyattutar BEFORE INSERT ON public.siparisurun FOR EACH ROW EXECUTE FUNCTION public.siparistoplamtutar();


--
-- TOC entry 3350 (class 2620 OID 16677)
-- Name: siparisurun siparis; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER siparis AFTER INSERT ON public.siparisurun FOR EACH ROW EXECUTE FUNCTION public.siparisurunarttir();


--
-- TOC entry 3351 (class 2620 OID 16761)
-- Name: siparisurun siparistoplamtutar; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER siparistoplamtutar BEFORE INSERT OR UPDATE ON public.siparisurun FOR EACH ROW EXECUTE FUNCTION public.siparistoplamtutar();


--
-- TOC entry 3352 (class 2620 OID 16777)
-- Name: siparisurun siparisurun_silme; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER siparisurun_silme BEFORE DELETE ON public.siparisurun FOR EACH ROW EXECUTE FUNCTION public.siparisurun_silme_fonksiyonu();


--
-- TOC entry 3353 (class 2620 OID 16760)
-- Name: yakit_tuketim yakit_maliyet_hesabi; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER yakit_maliyet_hesabi BEFORE INSERT OR UPDATE ON public.yakit_tuketim FOR EACH ROW EXECUTE FUNCTION public.yakit_maliyet_hesapla();


--
-- TOC entry 3330 (class 2606 OID 16678)
-- Name: calisan calisan_fk; Type: FK CONSTRAINT; Schema: calisan; Owner: postgres
--

ALTER TABLE ONLY calisan.calisan
    ADD CONSTRAINT calisan_fk FOREIGN KEY (bolum_id) REFERENCES public.depobolum(bolum_id) NOT VALID;


--
-- TOC entry 3336 (class 2606 OID 16683)
-- Name: sevkiyat aracsevkiyat_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sevkiyat
    ADD CONSTRAINT aracsevkiyat_fk FOREIGN KEY (arac_id) REFERENCES public.arac(arac_id) NOT VALID;


--
-- TOC entry 3333 (class 2606 OID 16688)
-- Name: depobolum bolumDepo_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depobolum
    ADD CONSTRAINT "bolumDepo_fk" FOREIGN KEY (depo_id) REFERENCES public.depo(depo_id) NOT VALID;


--
-- TOC entry 3334 (class 2606 OID 16693)
-- Name: depobolum bolumKategori_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depobolum
    ADD CONSTRAINT "bolumKategori_fk" FOREIGN KEY (kategori_id) REFERENCES public.kategori(kategori_id) NOT VALID;


--
-- TOC entry 3332 (class 2606 OID 16698)
-- Name: depobakım depobakım_depoİd_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."depobakım"
    ADD CONSTRAINT "depobakım_depoİd_fkey" FOREIGN KEY (depo_id) REFERENCES public.depo(depo_id);


--
-- TOC entry 3337 (class 2606 OID 16703)
-- Name: sevkiyat depoidsevkiyat_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sevkiyat
    ADD CONSTRAINT depoidsevkiyat_fk FOREIGN KEY (depo_id) REFERENCES public.depo(depo_id) NOT VALID;


--
-- TOC entry 3331 (class 2606 OID 16708)
-- Name: depo ilceno_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.depo
    ADD CONSTRAINT ilceno_fk FOREIGN KEY (ilce_no) REFERENCES public.ilce(ilce_no) NOT VALID;


--
-- TOC entry 3335 (class 2606 OID 16713)
-- Name: ilce ilno_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilce
    ADD CONSTRAINT ilno_fk FOREIGN KEY (il_no) REFERENCES public.il(il_no) NOT VALID;


--
-- TOC entry 3342 (class 2606 OID 16718)
-- Name: tedarikci kategoritedarik_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tedarikci
    ADD CONSTRAINT kategoritedarik_fk FOREIGN KEY (kategori_id) REFERENCES public.kategori(kategori_id) NOT VALID;


--
-- TOC entry 3338 (class 2606 OID 16723)
-- Name: sevkiyat sevkiyat_siparisNo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sevkiyat
    ADD CONSTRAINT "sevkiyat_siparisNo_fkey" FOREIGN KEY (siparis_no) REFERENCES public.siparisurun(siparis_no);


--
-- TOC entry 3339 (class 2606 OID 16728)
-- Name: siparisurun siparisfatura_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisurun
    ADD CONSTRAINT siparisfatura_fk FOREIGN KEY (fatura_no) REFERENCES public.fatura(fatura_no) NOT VALID;


--
-- TOC entry 3340 (class 2606 OID 16733)
-- Name: siparisurun siparisurun_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisurun
    ADD CONSTRAINT siparisurun_fk FOREIGN KEY (urun_kodu) REFERENCES public.urun(urun_kodu) NOT VALID;


--
-- TOC entry 3341 (class 2606 OID 16769)
-- Name: siparisurun siparisverencalisan_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisurun
    ADD CONSTRAINT siparisverencalisan_fk FOREIGN KEY (siparis_veren) REFERENCES public.depocalisanlar(calisan_id) NOT VALID;


--
-- TOC entry 3343 (class 2606 OID 16743)
-- Name: tedarikci tedarikci_ilceNo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tedarikci
    ADD CONSTRAINT "tedarikci_ilceNo_fkey" FOREIGN KEY (ilce_no) REFERENCES public.ilce(ilce_no);


--
-- TOC entry 3344 (class 2606 OID 16748)
-- Name: urun urunkategori_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urun
    ADD CONSTRAINT urunkategori_fk FOREIGN KEY (kategori_id) REFERENCES public.kategori(kategori_id) NOT VALID;


--
-- TOC entry 3345 (class 2606 OID 16753)
-- Name: yakit_tuketim yakıtTüketim_aracİd_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yakit_tuketim
    ADD CONSTRAINT "yakıtTüketim_aracİd_fkey" FOREIGN KEY (arac_id) REFERENCES public.arac(arac_id);


-- Completed on 2024-12-24 09:22:18

--
-- PostgreSQL database dump complete
--

