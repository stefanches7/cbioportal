package org.cbioportal.web;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.cbioportal.model.CancerStudy;
import org.cbioportal.service.StudyService;
import org.cbioportal.service.exception.StudyNotFoundException;
import org.cbioportal.web.parameter.Direction;
import org.cbioportal.web.parameter.HeaderKeyConstants;
import org.cbioportal.web.parameter.PagingConstants;
import org.cbioportal.web.parameter.Projection;
import org.cbioportal.web.parameter.sort.StudySortBy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@Api(tags = "Studies", description = " ")
public class StudyController {

    @Autowired
    private StudyService studyService;

    @RequestMapping(value = "/studies", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    @ApiOperation("Get all studies")
    public ResponseEntity<List<CancerStudy>> getAllStudies(
            @ApiParam("Level of detail of the response")
            @RequestParam(defaultValue = "SUMMARY") Projection projection,
            @ApiParam("Page size of the result list")
            @RequestParam(defaultValue = PagingConstants.DEFAULT_PAGE_SIZE) Integer pageSize,
            @ApiParam("Page number of the result list")
            @RequestParam(defaultValue = PagingConstants.DEFAULT_PAGE_NUMBER) Integer pageNumber,
            @ApiParam("Name of the property that the result list is sorted by")
            @RequestParam(required = false) StudySortBy sortBy,
            @ApiParam("Direction of the sort")
            @RequestParam(defaultValue = "ASC") Direction direction) {

        if (projection == Projection.META) {
            HttpHeaders responseHeaders = new HttpHeaders();
            responseHeaders.add(HeaderKeyConstants.TOTAL_COUNT, studyService.getMetaStudies().getTotalCount()
                    .toString());
            return new ResponseEntity<>(responseHeaders, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(
                    studyService.getAllStudies(projection.name(), pageSize, pageNumber,
                            sortBy == null ? null : sortBy.getOriginalValue(), direction.name()), HttpStatus.OK);
        }
    }

    @RequestMapping(value = "/studies/{studyId}", method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @ApiOperation("Get a study")
    public ResponseEntity<CancerStudy> getStudy(
            @ApiParam(required = true, value = "Study ID e.g. acc_tcga")
            @PathVariable String studyId) throws StudyNotFoundException {

        return new ResponseEntity<>(studyService.getStudy(studyId), HttpStatus.OK);
    }
}
