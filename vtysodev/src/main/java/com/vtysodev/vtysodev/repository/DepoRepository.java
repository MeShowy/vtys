package com.vtysodev.vtysodev.repository;

import com.vtysodev.vtysodev.model.Depo;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DepoRepository extends JpaRepository<Depo, Integer> {


    @Query(value = """
        SELECT * FROM public.depo
    """, nativeQuery = true)
    List<Depo> getDepoList();


    @Query(value = """
        SELECT * FROM public.depo WHERE depo_id = :depoId
    """, nativeQuery = true)
    Optional<Depo> getDepo(@Param("depoId") int depoId);


    @Modifying
    @Transactional
    @Query(value = """
        UPDATE public.depo
        SET ilce_no = :ilceNo, depo_adi = :depoAdi, kapasite = :kapasite
        WHERE depo_id = :depoId
    """, nativeQuery = true)
    void updateDepo(@Param("depoId") Integer depoId, @Param("ilceNo") Integer ilceNo,
                    @Param("depoAdi") String depoAdi, @Param("kapasite") Integer kapasite);


    @Modifying
    @Transactional
    @Query(value = """
        INSERT INTO public.depo (ilce_no, depo_adi, kapasite)
        VALUES (:ilceNo, :depoAdi, :kapasite)
    """, nativeQuery = true)
    void saveDepo(@Param("ilceNo") Integer ilceNo, @Param("depoAdi") String depoAdi,
                  @Param("kapasite") Integer kapasite);
}
