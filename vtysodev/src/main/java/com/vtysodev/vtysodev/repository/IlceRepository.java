package com.vtysodev.vtysodev.repository;


import com.vtysodev.vtysodev.model.Ilce;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface IlceRepository extends JpaRepository<Ilce, Integer> {


    @Query(value = """
        SELECT * FROM public.ilce
    """, nativeQuery = true)
    List<Ilce> getIlceler();



}
