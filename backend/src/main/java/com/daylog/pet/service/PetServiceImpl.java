package com.daylog.pet.service;

import com.daylog.pet.entity.Pet;
import com.daylog.pet.entity.Type;
import com.daylog.pet.repository.PetRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class PetServiceImpl implements PetService {
    private final PetRepository petRepository;

    @Override
    public Pet createPetAndReturn() {
        Pet pet = Pet.builder()
                .name("개")
                .type(Type.DOG)
                .build();
        petRepository.save(pet);
        return pet;
    }
}
