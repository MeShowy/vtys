package com.vtysodev.vtysodev.repository;

import com.vtysodev.vtysodev.model.Arac;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;


import java.util.List;
import java.util.Optional;

@Repository
public interface AracRepository extends JpaRepository<Arac, Integer> {

    @Query(value = """

            DELETE FROM public.arac
    	WHERE "arac_id" = :aracId""",nativeQuery = true)
    @Transactional
    @Modifying
    void deleteArac(@Param("aracId") Integer aracId);

    @Query( value = """
    SELECT "arac_id", "arac_tipi" FROM public.arac
    """,nativeQuery = true)
    List<Arac> getAracList();

    @Query(value = """
    SELECT "arac_id", "arac_tipi" FROM public.arac where "arac_id" = :aracId
    """,nativeQuery = true)
    Optional<Arac> getArac(@Param("aracId") int aracId);

    @Modifying
    @Transactional
    @Query(value = """
    UPDATE public.arac
    	SET arac_id=:aracId, arac_tipi=:aracTipi
    	WHERE arac_id = :aracId
""",nativeQuery = true)
    void updateArac(Integer aracId, String aracTipi);

    @Modifying
    @Query(value = """
    insert INTO public.arac(arac_id, arac_tipi) VALUES (default,:aracTipi)
""", nativeQuery = true)
    @Transactional
    void saveArac(String aracTipi);




}
