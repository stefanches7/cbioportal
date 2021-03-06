package org.cbioportal.service.impl;

import org.cbioportal.model.GeneticProfile;
import org.cbioportal.model.meta.BaseMeta;
import org.cbioportal.persistence.GeneticProfileRepository;
import org.cbioportal.service.GeneticProfileService;
import org.cbioportal.service.exception.GeneticProfileNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GeneticProfileServiceImpl implements GeneticProfileService {

    @Autowired
    private GeneticProfileRepository geneticProfileRepository;

    @Override
    public List<GeneticProfile> getAllGeneticProfiles(String projection, Integer pageSize, Integer pageNumber,
                                                      String sortBy, String direction) {

        return geneticProfileRepository.getAllGeneticProfiles(projection, pageSize, pageNumber, sortBy, direction);
    }

    @Override
    public BaseMeta getMetaGeneticProfiles() {

        return geneticProfileRepository.getMetaGeneticProfiles();
    }

    @Override
    public GeneticProfile getGeneticProfile(String geneticProfileId) throws GeneticProfileNotFoundException {

        GeneticProfile geneticProfile = geneticProfileRepository.getGeneticProfile(geneticProfileId);
        if (geneticProfile == null) {
            throw new GeneticProfileNotFoundException(geneticProfileId);
        }

        return geneticProfile;
    }

    @Override
    public List<GeneticProfile> getAllGeneticProfilesInStudy(String studyId, String projection, Integer pageSize,
                                                             Integer pageNumber, String sortBy, String direction) {

        return geneticProfileRepository.getAllGeneticProfilesInStudy(studyId, projection, pageSize, pageNumber, sortBy,
                direction);
    }

    @Override
    public BaseMeta getMetaGeneticProfilesInStudy(String studyId) {
        return geneticProfileRepository.getMetaGeneticProfilesInStudy(studyId);
    }
}
