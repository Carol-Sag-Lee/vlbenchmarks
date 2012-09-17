classdef CvSift < localFeatures.GenericLocalFeatureExtractor & ...
    helpers.GenericInstaller
% CVSIFT feature extractor wrapper of OpenCV SIFT detector
%
% Feature Extractor wrapper around the OpenCV SIFT detector. This class
% constructor accepts the same options as localFeatures.mex.cvSift
%
% This detector depends on OpenCV library.
%
% See also: localFeatures.mex.cvSift helpers.OpenCVInstaller

% AUTORIGHTS
  properties (SetAccess=public, GetAccess=public)
    cvsift_arguments
    binPath
  end

  methods
    function obj = CvSift(varargin)
      obj.name = 'OpenCV SIFT';
      obj.detectorName = obj.name;
      obj.descriptorName = obj.name;
      obj.extractsDescriptors = true;
      varargin = obj.checkInstall(varargin);
      varargin = obj.configureLogger(obj.name,varargin);
      obj.cvsift_arguments = obj.configureLogger(obj.name,varargin);
      obj.binPath = {which('localFeatures.mex.cvSift')};
    end

    function [frames descriptors] = extractFeatures(obj, imagePath)
      import helpers.*;
      import localFeatures.*;
      [frames descriptors] = obj.loadFeatures(imagePath,nargout > 1);
      if numel(frames) > 0; return; end;
      img = imread(imagePath);
      if(size(img,3)>1), img = rgb2gray(img); end
      img = uint8(img);
      startTime = tic;
      if nargout == 1
        obj.info('Computing frames of image %s.',getFileName(imagePath));
        [frames] = localFeatures.mex.cvSift(img,obj.cvsift_arguments{:});
      else
        obj.info('Computing frames and descriptors of image %s.',...
          getFileName(imagePath));
        [frames descriptors] = mex.cvSift(img,obj.cvsift_arguments{:});
      end
      timeElapsed = toc(startTime);
      obj.debug('Frames of image %s computed in %gs',...
        getFileName(imagePath),timeElapsed);
      obj.storeFeatures(imagePath, frames, descriptors);
    end
    
    function [frames descriptors] = extractDescriptors(obj, imagePath, frames)
      import localFeatures.*;
      img = imread(imagePath);
      if(size(img,3)>1), img = rgb2gray(img); end
      img = uint8(img);
      startTime = tic;
      [frames descriptors] = mex.cvSift(img,'Frames', ...
        frames,obj.cvsift_arguments{:});
      timeElapsed = toc(startTime);
      obj.debug('Descriptors of %d frames computed in %gs',...
        size(frames,2),timeElapsed);
    end

    function sign = getSignature(obj)
      sign = [helpers.fileSignature(obj.binPath{:}) ';'...
              helpers.cell2str(obj.cvsift_arguments)];
    end
  end

  methods (Static)
    function deps = getDependencies()
      deps = {helpers.Installer() helpers.VlFeatInstaller('0.9.15') ...
        helpers.OpenCVInstaller()};
    end

    function [srclist flags] = getMexSources()
      import helpers.*;
      path = fullfile(pwd,'+localFeatures','+mex','');
      srclist = {fullfile(path,'cvSift.cpp')};
      flags = {[OpenCVInstaller.MEXFLAGS ' ' VlFeatInstaller.MEXFLAGS ]};
    end
  end
end
